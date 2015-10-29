#encoding: utf-8
#encode: utf-8
require 'fileutils'
require 'json'

class Getter < WEBrick::HTTPServlet::AbstractServlet
	def do_GET(request, response)
		id = request.query["reportID"]
		request.query.each{|key, value|
			puts "request[#{key}] = #{value}"
		}

		if (id!=nil)
			if (File.exist?("./attInRange/Report/#{id}.ok"))
				response.status = 200
				response['Content-Type'] = "text/html"
				response.body = IO.read("./attInRange/Report/#{id}.html")
			else
				response.status = 200
				response['Content-Type'] = "text/html"
				response.body = "Ваш отчет пока не готов. Повторите запрос через минуту."
			end
		else
			response.status = 302
			response['Location'] = "#{request.path.gsub("get", "rep")}"
		end
	end
end