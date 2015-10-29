#encoding: utf-8
#encode: utf-8
require 'rubygems'
require 'json'
require 'pp'
#require 'hashie'

class BaseParameterParser

	def initialize(path)
		@source = path
	end

=begin
	def setMash
		begin
			json = File.read(@source)
		rescue Exception => e
			puts "Invalid source path. \n\t#{e}"
			return false
		end

		begin 
			hash = JSON.parse json
			@objectMash = Hashie::Mash.new hash
		rescue Exception => e
			puts "Invalid json file. \n\t#{e}"
		end

		return true
	end
=end

	def setHash
		begin
			json = File.read(@source)
		rescue Exception => e
			puts "Invalid source path. \n\t#{e}"
			return false
		end

		begin 
			@hash = JSON.parse json
		rescue Exception => e
			puts "Invalid json file. \n\t#{e}"
		end

		return true
	end

	:hash
	:source
	:objectMash
end