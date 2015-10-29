#encoding=utf-8
#encode: utf-8
require "#{File.dirname(__FILE__)}/Html/HtmlBase.rb"
require "#{File.dirname(__FILE__)}/BaseRequester"
require "#{File.dirname(__FILE__)}/Constants.rb"
require "#{File.dirname(__FILE__)}/AttInRegionParameters.rb"

require 'json'
class RequesterManager < BaseRequesterEx
	def initialize(patameterPath)
		STDOUT.sync = true
		@rawReports = {}
		@rawReports["rawReport"] = []
		@pendingRequests = []
		@requestToDelete = []
		@max_request_count = Const::PROCESS_COUNT
		@parameterParser = AttInRegionParameters.new(patameterPath) #Source Data Parser
		@isDataExists = true
	end

	def getReport
		return @rawReports
	end

	def checkReportReady(pendingRequest)
		params = {"id" => "#{pendingRequest.id}", "clear" => "true"}

		response = execute(Const::DOMAIN, Const::ATTINREGION_CHECK_REPORT, params)
		hash = JSON.parse response.body 
		if (hash["status"]=="ready")
			p "checkReportReady #{pendingRequest.id} ok"
			
			hash["req_parameters"] = pendingRequest.parameters
			@rawReports["rawReport"] << hash
			return true
		end
		p "checkReportReady #{pendingRequest.id} false"
		return false
	end

	def sendRequest
		parameters = @parameterParser.getNextParameters
		if (parameters == nil)
			@isDataExists = false
			puts "\nNO MORE DATA\n"
			return false
		end
		
		name = @parameterParser.getCurrentMagistralName
		interval = @parameterParser.getCurrentInterval
		response = execute(Const::DOMAIN, Const::ATTINREGION_REQUEST_REPORT, parameters)
		
		if (response!=nil)
			if (response.code.to_i==200)
				hash = JSON.parse response.body
				id = hash["id"]
				h = parameters.clone
				h["region_name"] = name

				pr = PendingRequest.new(id, h)
				@pendingRequests << pr
			else
				puts "\nRESPONSE CODE != 200!"
			end
		
		else
			puts "\nRESPONSE == nil"
		end
		return true
	end

	def sendPollRequest(parameters)
		if (parameters==nil)
			puts "\nNO POLLING PARAMETERS"
			return nil
		end

		response = execute(Const::DOMAIN, Const::POLLING_REQUEST, parameters)
		if (response!=nil)
			if (response.code.to_i==200)
				print "."
				hash = JSON.parse response.body
				return hash
			else
				p "\nRESPONSE CODE != 200!"
			end
		else
			p "\nRESPONSE == nil"
		end



	end

	def run
		while(@isDataExists || @pendingRequests.size!=0)
			while (@isDataExists)
				if (@pendingRequests.size < @max_request_count)
					#Больше нет данных для запроса
					sendRequest
				else
					#Заполнен стек запросов
					break
				end
			end

			if (@pendingRequests.size!=0)
				@pendingRequests.each{|pendingRequest|
					if(checkReportReady(pendingRequest))
						@requestToDelete << pendingRequest
					end
				}

				if (@requestToDelete.size!=0)
					@requestToDelete.each{|item_to_delete|
						@pendingRequests.delete(item_to_delete)
					}
				end
			end

			sleep(5)
		end

		@rawReports["rawReport"].each{|report|
			puts "\nGet polling\nreport_id = #{report["id"]}\n"
			report["result"].each{|vehicle_data|	
				params = {"id" => "#{vehicle_data["ident"]}", "start" => "#{vehicle_data["starttime"].gsub(" ","T")}", "end" => "#{vehicle_data["endtime"].gsub(" ","T")}", "interval" => ""}
				polling = sendPollRequest(params)

=begin
				h = {}
				polling.each_key{|key|
					h[key] = []
				}
				polling.each{|key, value|
					h[key] << value[0]
					h[key] << value[1]
				}
				vehicle_data["polling"] = h
=end
				vehicle_data["polling"] = polling
			}
		}
	end

	:isDataExists
	:requestToDelete
	:pendingRequests
	:parameterParser
	:reports
	:max_request_count
end

class PendingRequest
	def initialize(id, parameters)
		puts "PendingRequest (#{id}), parameters #{parameters["region_name"].encode("cp866")}"
		@id = id
		@parameters = parameters
	end

	attr_accessor :id
	attr_accessor :parameters
end

=begin
	#RUNNER!
	t =  Time.now.strftime("%d-%m-%Y_%H-%M")
	rm = RequesterManager.new(patameterPath)
	rm.run
	hash = rm.getReport
	rep = ReportParser.new(hash, t)
=end