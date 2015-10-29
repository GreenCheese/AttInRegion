#encoding=utf-8
#encode: utf-8
require "#{File.dirname(__FILE__)}/attInRange/BaseRequester.rb"
require "#{File.dirname(__FILE__)}/Paths.rb"
require "#{File.dirname(__FILE__)}/attInRange/Constants.rb"
require 'json'

class RnisRequester < BaseRequesterEx
	def initialize(cookie)
		setCookie(cookie)
	end

	def getLabelsRequest
		labels = []
		magicCode = 919476
		params = {"id" => "93908", "rel" => "labelstree,label"}
		response = execute(Const::DOMAIN, Paths::SYSOBJ, params)
		if (response==nil)
			return nil
		end
		body = JSON.parse response.body
		body["result"]["#{magicCode}"].each{|item|
			labels << {"key" => "#{item["key"]}", "name" => "#{item["name"].encode("cp866")}" }
		}
		return labels
	end

	def getAttType
		types = []
		magicCode = 10164
		params = {"id" => "7540", "rel" => "typestree"}
		response = execute(Const::DOMAIN, Paths::SYSOBJ, params)
		if (response==nil)
			return nil
		end

		body = JSON.parse response.body
		body["result"]["#{magicCode}"].each{|item|
			types << {"key" => "#{item["key"]}", "name" => "#{item["name"].encode("cp866")}" }
		}

		return types
	end

	def getRegionGeometry(id)
		params = {"id" => id}
		response = execute(Const::DOMAIN, Paths::OBJPROPERTIES, params)
		if (response==nil)
			return nil
		end
		
		body = JSON.parse response.body

		return body["result"]["magistralGeom"]
	end

	def getRegions
		regions = []
		params = {"id" => "3414961", "start" => "0", "limit" => "100"}
		response = execute(Const::DOMAIN, Paths::TREENODECHILD, params)
		if (response==nil)
			return nil
		end

		body = JSON.parse response.body
		body["result"].each{|item|
			oid = item["oid"]
			name = item["name"]
			geometry = getRegionGeometry(oid)
			regions << {"oid" => oid, "name" => "#{name}", "geometry" => geometry}
		}
		return regions
	end
end