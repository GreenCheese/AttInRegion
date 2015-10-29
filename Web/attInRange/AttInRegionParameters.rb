#encoding: utf-8
#encode: utf-8
require "#{File.dirname(__FILE__)}/BaseParameterParser.rb"
require "#{File.dirname(__FILE__)}/Constants.rb"

class AttInRegionParameters < BaseParameterParser
	def initialize(patameterPath)
		@m = 0
		@m_count = 0
		@i = 0
		@i_count = 0
		@current_magistral_name = ""
		@current_interval = nil
		@is_loaded = false
		super(patameterPath)
	end

	def loadParameters
		if (setHash)
			@restParameters = @hash["restParameters"]
			@magistrals = @hash["magistrals"]
			@intervals = @hash["intervals"]

			@m_count = @magistrals.size
			@i_count = @intervals.size
			@is_loaded = true
		end
	end

=begin
	def loadParameters
		if (setMash)
			@magistrals = @objectMash.magistrals
			@intervals = @objectMash.intervals
			@includeSubtypes = @objectMash.restParameters.includeSubtypes
			@interval = @objectMash.restParameters.interval
			@vislable = @objectMash.restParameters.vislable
			@atttype = @objectMash.restParameters.atttype

			@m_count = @magistrals.size
			@i_count = @intervals.size
			@is_loaded = true
		end
	end
=end

	def setCurrentParameters
		@current_interval = @intervals[@i]
		@current_magistral_name = @magistrals[@m]["name"]
	end

	def getCurrentMagistralName
		return @current_magistral_name
	end

	def getCurrentInterval
		return @current_interval
	end

	def getNextParameters
		if(!@is_loaded)
			loadParameters
		end

		if (@m == @m_count)
			@m = 0
			@i = @i + 1
		end

		if (@i == @i_count)
			return nil
		end

		parameterHash = {}
		parameterHash = @restParameters
				
		parameterHash.merge!(@intervals[@i])
		parameterHash.merge!("region" => "[["+@magistrals[@m]["region"]+"]]")
	
		setCurrentParameters
		@m = @m + 1

		return parameterHash
	end

	:magistrals
	:intervals

	:m 
	:m_count
	:i
	:i_count
	:current_magistral_name
	:current_interval

	:is_loaded
	:restParameters
end