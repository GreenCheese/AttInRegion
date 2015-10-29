#encoding: utf-8
#encode: utf-8
require 'fileutils'
require 'json'
require "#{File.dirname(__FILE__)}/attInRange/RequestManager.rb"

class Sender < WEBrick::HTTPServlet::AbstractServlet
	def do_GET(request, response)
		i = 0
		region_id_arr = []
		startTimes = []
		endTimes = []

		while (request.query["region[#{i}]"]!=nil)
			region_id_arr << request.query["region[#{i}]"]
			i = i + 1
		end
		
		vislable = request.query["vislable"]
		i = 1

		while (request.query["startTime[#{i}]"]!=nil)
			startTimes << request.query["startTime[#{i}]"].gsub(" ", "T")+":00"
			endTimes << request.query["endTime[#{i}]"].gsub(" ", "T")+":00"
			i = i + 1
		end

		atttype = request.query["atttype"]
		includeSubtypes = request.query["includeSubtypes"]
		interval = request.query["interval"]

		hashParameters = {}
		hashParameters["magistrals"] = []
		hashParameters["intervals"] = []
		hashParameters["restParameters"] = {}

		cookie = request["Cookie"]
		rr = RnisRequester.new(cookie)
		regions = rr.getRegions

		regions.each{|item|
			region_id_arr.each{|req_id|
				if(req_id.to_i==item["oid"])
					name = item["name"]
					geometryArr = item["geometry"][0]
					geometry = ""
					geometryArr.each{|item|
		  				geometry = geometry + "#{item},"
					}
					geometry = geometry[0..-2]

					magitem = {}
					magitem["name"] = name
					magitem["region"] = geometry
					hashParameters["magistrals"] << magitem
				end
			}
		}

		for i in 0..startTimes.size-1
			intitem = {}
			intitem["startTime"] = startTimes[i]
			intitem["endTime"] = endTimes[i]
			hashParameters["intervals"] << intitem
		end

		hashParameters["restParameters"]["includeSubtypes"] =	includeSubtypes
		hashParameters["restParameters"]["interval"] 		=	interval
		hashParameters["restParameters"]["atttype"] 		=	atttype
		hashParameters["restParameters"]["vislable"] 		=	vislable

		hashParametersJson = hashParameters.to_json

		filename = "nextreportid"
		path = "./attInRange/Report"
		f =  IO.read(path+"/#{filename}")
		intId = f.to_i

		reppath = path+ "/#{f.strip}"
		FileUtils.mkpath reppath
		f = File.new(path+"/#{filename}", "wb+")
		f.write(intId+1)
		f.close

		parameterPath = reppath+"/regionsData.json"
		p parameterPath

		f = File.new(parameterPath, "wb+")
		f.write(hashParametersJson)
		f.close

		rm = RequesterManager.new(parameterPath)
		rm.setCookie(cookie)
		rm.run
		hash = rm.getReport

		rep = ReportParser.new(hash, "#{path}/#{intId}")
		#rep = ReportParser.new(hash, "#{intId}")
        
        response.status = 200
        response['Content-Type'] = "text/html"
        response.body = "ID вашего отчета #{intId}.\nИспользуйте этот номер для получения отчета.\nОтчет будет доступен после подготовки данных"
	end
end