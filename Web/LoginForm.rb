#encoding: utf-8
#encode: utf-8
require "#{File.dirname(__FILE__)}/attInRange/BaseRequester.rb"
require "#{File.dirname(__FILE__)}/RnisRequester.rb"
require 'erb'

class LoginForm < WEBrick::HTTPServlet::AbstractServlet
	def logout(response)
		response.status = 302
		response['Content-Type'] = "text/html"
		response['Location'] = "/logout"
	end

	def loadBody(cookie)
		#TODO Check login
		rr = RnisRequester.new(cookie)
		labels = rr.getLabelsRequest
		if labels==nil
			return nil
		end
      
		s_erb_labels = ""
		s_erb_atttyle = ""
		s_erb_regions = ""
		s_erb_regions_script = ""
		atttypes = rr.getAttType
		regions = rr.getRegions

		labels.each{|item|
			s_erb_labels = s_erb_labels + "<option>#{item["key"]}</option>\n"
		}

		atttypes.each{|item|
			s_erb_atttyle = s_erb_atttyle + "<option>#{item["key"]}</option>\n"
		}

		regions.each{|item|
			name = item["name"]
			oid = item["oid"]
			geometryArr = item["geometry"][0]
			geometry = ""
			
			geometryArr.each{|item|
				geometry = geometry + "#{item}, "
			}
			geometry = geometry[0..-3]

			s_erb_regions = s_erb_regions + "<option value ='#{item["oid"]}'>#{name}</option>\n"
			s_erb_regions_script = s_erb_regions_script + "<tr><td>#{oid}</td><td>#{name}</td><td>#{geometry}</td></tr>\n"
		}

		html = ERB.new(IO.read('html/attinrangeform.html').force_encoding("utf-8")).result(binding)
		return html.encode("utf-8")
	end

	def do_GET(request, response)
		if(request["Cookie"]==nil or request["Cookie"]=="" or request["Cookie"].split('; ')[0]=="JSESSIONID=\"\"")
			status, content_type, body = print_form(request)
			response.status = status
			response['Content-Type'] = content_type
			response.body = body
		else
			body = loadBody(request["Cookie"])
			if (body!=nil)
				response.body = body
				response['Content-Type'] = "*/*"
			else
				logout(response)
			end
		end
	end

	def print_form(request)
		html = ERB.new(IO.read('getLoginPage')).result
		return 200, "text/html", html
  	end
end

