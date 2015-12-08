require 'net/http'
require 'uri'
require 'CGI'
require 'json'
require "#{File.dirname(__FILE__)}/Constants.rb"

class BaseRequester
	def initialize
		@uri = nil
	end

	def setUriFromUrl(url)
		begin
			@uri = URI.parse(url)
		rescue Exception => e
			puts "\nInvalid url. \n\t#{e}"
			return false
		end
		return true
	end

	def http_get(domain,path,params, cookie=nil)
		if params!=nil
			url = "#{domain}#{path}"+params.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&')
		else
			if (path!="")
				url = "#{domain}#{path}" 
			else
				url = "#{domain}" 
			end
		end

		if (setUriFromUrl(url))
			http = Net::HTTP.new(@uri.host, @uri.port)
			if (cookie!=nil)	
				headers = {
 					'Cookie' => cookie
 				}
 				request = Net::HTTP::Get.new(@uri.request_uri, headers)
			else
				request = Net::HTTP::Get.new(@uri.request_uri)
			end

			return http.request(request)
		end

		return nil
	end

	def http_post(domain,path,params, cookie=nil)
		url = domain+path
		if (setUriFromUrl(url))
			http = Net::HTTP.new(@uri.host, @uri.port)
			if (cookie!=nil)	
				headers = {
 					'Cookie' => cookie
 				}
 				request = Net::HTTP::Post.new(@uri.request_uri, headers)
			else
				request = Net::HTTP::Post.new(@uri.request_uri)
			end
			
			request.set_form_data(params)
			return http.request(request)
		end

		return nil
	end
	
	:remoteServer
	:uri
end

class BaseRequesterEx < BaseRequester
	@cookie = nil

	def setCookie(cookie)
		@cookie = cookie
	end

	def getCookie
		return @cookie
	end

	def getDomain(response)
		begin
			uri = URI.parse(response['location'])
		rescue Exception => e
			puts "\ngetDomain: Invalid response. \n\t#{e}"
			return ""
		end
		return uri.scheme+"://"+uri.host
	end

	def getRequest_uri(response)
		begin
			uri = URI.parse(response['location'])
		rescue Exception => e
			puts "\ngetRequest_uri: Invalid response. \n\t#{e}"
			return ""
		end
		
		return uri.request_uri
	end

	#TODO: Make redirect via execute
	def auth(domain, path, parameters)
		#POST AUTH
		response = http_post(domain, path, parameters)

		if (response!=nil)
			if (response["Location"]!=Const::ERRACHECK)
				puts "AUTH SUCCESS"
				setCookie(response['set-cookie'].split('; ')[0])
			else
				puts "AUTH FAIL"
				return response
			end
		end
		
		#GET REDIRRECT SUCCESS-LOGIN
		response = http_get(getDomain(response), getRequest_uri(response), nil, @cookie)

		#GET REDIRRECT DOMAIN
		response = http_get(getDomain(response), getRequest_uri(response), nil, @cookie)

		return response
	end

	def execute(domain, path, parameters)
		if (@cookie==nil)
			f = IO.read(Const::LOGIN)
			params = JSON.parse f
			auth(domain, Const::ACHECK, params)
		end

		response = http_get(domain, path, parameters, @cookie)
		
		case response.code.to_i
		when 302
			puts "302"
			if (response.code.to_i == 200)
				return http_get(domain, path, parameters, @cookie)
			end

		when 200
			#puts "200"
			return response
		else
			puts "UNEXPECTED CODE: #{response.code}"
		end
		return nil
	end
end