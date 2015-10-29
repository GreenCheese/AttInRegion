class CheckLogin < WEBrick::HTTPServlet::AbstractServlet
	def do_POST(request, response)
		status, content_type, body = logginin(request)
		
		if (status!=200)
			response.body = body
			response.status = status
		else
			response.status = 302
			response['Location'] = "/"
			response['set-cookie']= body
		end

		response['Content-Type'] = content_type
	end

	def logginin(request)
		br = BaseRequesterEx.new
		login = request.query['user_name']
		password = request.query['password']

		params = {j_username: login, j_password:password}
		resp = br.auth(Const::DOMAIN, Const::ACHECK, params)

		if (resp.code !="200")
			return resp.code, "text/plain", "Bad Login!"
		else
			cookie = br.getCookie
			return 200, "text/html", cookie
		end
	end
end