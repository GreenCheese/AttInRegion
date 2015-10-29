require "#{File.dirname(__FILE__)}/attInRange/BaseRequester.rb"
require "#{File.dirname(__FILE__)}/RnisRequester.rb"
require 'erb'
class Logout < WEBrick::HTTPServlet::AbstractServlet
	def do_GET(request, response)
		response.status = 302
		response['Location'] = "/"
		response['set-cookie'] = "JSESSIONID=\"\"; Expires=#{Date.new(1971,1,1)}"#; path=/"
	end
end