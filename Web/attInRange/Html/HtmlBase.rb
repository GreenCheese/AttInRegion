require 'json'
require 'fileutils'
class HtmlBase
	:filename
	:header
	:footer
	def initialize(filename)
		@filename = filename
		@header 		= "<!DOCTYPE HTML><html><head><meta charset=\"utf-8\"><title>-=3#E=-</title></head><body><table border = \"1\" cellpadding=\"4\" style=\"border-collapse: collapse; border: 1px solid black;\">"
		@footer 		= "</table></body></html>"
	end

end

class FileCreator
	:mode
	:descriptor
	def initialize(filepath, mode)
		@mode = mode
		checkFilepath(filepath)
		@descriptor = File.new(filepath, mode)
		return @descriptor
	end

	def checkFilepath(filepath)
		fpArr = filepath.split("/")
		if(fpArr.size==1)
			return
		end
		path = ""
		for i in 0..fpArr.size-2
			path = path + fpArr[i]+"/"
		end

		begin
			FileUtils.mkpath path
		rescue Exception => e
			
		end
	end

	def write(str)
		@descriptor.write(str)
	end

	def close
		@descriptor.close
	end

end

class HtmlTable < HtmlBase
	def initialize(filename)
		super(filename)
	end

	def createHtml(table)
		html = FileCreator.new(@filename, "wb+")
		html.write(@header)

		lines = table.size
		rows = table[0].size

		for l in 0..lines-1
			str = "<tr>"
			for r in 0..rows-1
				cell = table[l][r]
				if(cell.getHref!=nil)
					str = "#{str}<td><a href=\"#{cell.getHref}\">#{cell.getValue.to_s}</a></td>"
				else
					str = "#{str}<td>#{cell.getValue.to_s}</td>"
				end
			end
			str = str + "</tr>\n"
			html.write(str)
		end
		html.write(@footer)
		html.close
	end
end

class HtmlPlain < HtmlBase
	:top
	:bottom
	def initialize(filename, top, bot)
		@top = top
		@bottom = bot
		super(filename)
	end

	def createHtml(innerPart)
		html = FileCreator.new(@filename, "wb+")
		
		ft=IO.read(@top)
		html.write(ft)
		html.write(innerPart)
		fb=IO.read(@bottom)
		html.write(fb)
		html.close
	end
end

class TableCell
	:value
	:href
	def initialize(value, href=nil)
		@value = value
		@href = href
	end

	def getHref
		return @href
	end

	def getValue
		return @value
	end

end

class TableH
	:table
	:ht
	def initialize(name)
		@ht = HtmlTable.new(name)
	end

	def setSize(lines, rows)
		@table = Array.new(lines)
		for i in 0..lines-1
			@table[i] = Array.new(rows)
		end
	end

	def addItem(item, line, row)
		@table[line][row] = item
	end

	def write
		@ht.createHtml(@table)
	end
end

class PlainText
	:text
	:hp
	:top
	:bot
	
	def initialize(filename)

		@top = "./attInRange/Html/top"
		@bot = "./attInRange/Html/bot"
		@text = []
		@hp = HtmlPlain.new(filename, @top, @bot)
	end

	def addItem(item)
		@text << item
	end

	def write
		str = ""
		@text.each{|item|
			str = str + item
		}
		@hp.createHtml(str)
	end

end


class ReportParser
	:hashReport
	:preparedForHtml
	:region
	:mainFilename
	def initialize(hashReport, mainFilename)

		@mainFilename = mainFilename
		@hashReport = hashReport
		@preparedForHtml = []
		@allVehData = ""
		@region = ""
		@strRegion = ""
		p "Parser: Start parsing"
		parse
		p "Parser: Print result"
		print
	end

	def print
		@preparedForHtml.each{|th|
			th.write
		}
		f = File.new("#{@mainFilename}.ok", "wb+")
		f.close
	end

	def parse
		names = []
		start_end = []
		@hashReport["rawReport"].each{|element|
			names << element["req_parameters"]["region_name"]
			from = element["req_parameters"]["startTime"].to_s
		 	to = element["req_parameters"]["endTime"].to_s
			start_end << [from, to]
		}
		
		names.uniq!
		start_end.uniq!
		filename = @mainFilename
		tm = TableH.new("#{filename}.html")
		tm.setSize(names.size+1,start_end.size+1)
		for l in 0..names.size
			for r in 0..start_end.size
				if (l==0 and r==0)
					tc = TableCell.new("")
					tm.addItem(tc,l,r)
				end
				
				if (l==0 and r!=0)
					s_st_end = "#{start_end[r-1][0]}---#{start_end[r-1][1]}".gsub("T", " ")
					tc = TableCell.new(s_st_end)
					tm.addItem(tc, l,r)
				end

				if (l!=0 and r==0)
					name = names[l-1].encode("cp866")
					tc = TableCell.new(name)
					tm.addItem(tc, l,r)
				end

				if (l!=0 and r!=0)
					@hashReport["rawReport"].each{|element|
						
						
						e_name = element["req_parameters"]["region_name"]
						e_start = element["req_parameters"]["startTime"].to_s
						e_end = element["req_parameters"]["endTime"].to_s

						if e_name==names[l-1] and e_start==start_end[r-1][0] and e_end = start_end[r-1][1]
							@region=element["req_parameters"]["region"]
							parse2(element["result"], "#{filename}/#{l}#{r}")
							@region=""
							value = element["result"].size
							tc = TableCell.new(value, "#{filename.split("/")[-1]}/#{l}#{r}.html")
							tm.addItem(tc, l, r)
						end
					}
				end
			end
		end
		@preparedForHtml<<tm
	end

	def parse2(hashTable, filename)
		
		fields = ["key", "type", "name", "count", "starttime", "endtime","intersections", "timeinregion", "pointsinregion"]
		
		

		tm = TableH.new("#{filename}.html")
		tm.setSize(hashTable.size+1, fields.size)
		@allVehData = ""
		
		for l in 0..hashTable.size
			hasVehData = false
			for r in 0..fields.size-1
				if (l==0)
					item = fields[r]
					
					tc = TableCell.new(item)
					tm.addItem(tc,l,r)
				else
					item = hashTable[l-1][fields[r]]
					#p hashTable[l-1]["polling"]
					
					if (r==0)
						tc = TableCell.new(item, "#{filename.split("/")[-1]}/#{item}.html")
						#tc = TableCell.new(item, "#{filename}/#{item}.html")

						hasVehData = parse3(hashTable[l-1]["polling"], "#{filename}/#{item}")
					else
						tc = TableCell.new(item)
					end
					tm.addItem(tc,l,r)
				end
			end

			if(l<hashTable.size)
				if (@allVehData!="" and hasVehData)
					@allVehData = @allVehData + ",\n"
				end
			end
		end
		
		#Add href for all vehicles
		tc = TableCell.new(fields[0], "#{filename.split("/")[-1]}/all.html")
		tm.addItem(tc,0,0)
		
		
		@allVehData = "var vehicleData =["+@allVehData+"];\n"

		pt = PlainText.new("#{filename}/all.html")
		pt.addItem(@strregion)
		pt.addItem(@allVehData)
		@preparedForHtml<<pt

		@preparedForHtml<<tm
	end

	def addVehDataText(str)
		#@allVehData <<"#{str}"
		
	end

	def parse3(pollingData, filename)
		if(pollingData.size==0)
			tm = TableH.new("#{filename}.html")
			tm.setSize(1,1)
			tc = TableCell.new("No data")
			tm.addItem(tc,0,0)
			@preparedForHtml<<tm

			return false
		end
		pt = PlainText.new("#{filename}.html")
		regArray = JSON.parse(@region)[0]
		strregion = "var region = [\n"
		

		for i in 0..regArray.size/2-1
			if (i<regArray.size/2-1)
				str = "{lng: #{regArray[i*2]}, lat: #{regArray[i*2+1]}},\n"
			else
				str = "{lng: #{regArray[i*2]}, lat: #{regArray[i*2+1]}}\n"
			end
			strregion = strregion + str
		end
		strregion = strregion + "];\n"

		@strregion = strregion

		strVehDataStart = "var vehicleData =["
		strVehDataEnd = "];\n"

		strMidData ="[\n"
		for i in 0..pollingData["times"].size-1
			if (pollingData["times"][i]!=nil)
				lng = pollingData["lon"][i]
				lat = pollingData["lat"][i]
				time = Time.at((pollingData["times"][i])/1000).to_s
				speed = pollingData["speed"][i]
				bearing = pollingData["bearing"][i]

				if (i<pollingData["times"].size-1)
					str = "{lng: #{lng}, lat: #{lat}, time: \"#{time}\", speed: #{speed}, bearing: #{bearing}},\n"
				else
					str = "{lng: #{lng}, lat: #{lat}, time: \"#{time}\", speed: #{speed}, bearing: #{bearing}}\n"
				end
				strMidData = strMidData + str
			end
		end
		strMidData = strMidData+ "]"
		
		@allVehData = @allVehData+strMidData
		strVehData = strVehDataStart+strMidData+strVehDataEnd
		#p strVehData



			
		pt.addItem(strregion)
		pt.addItem(strVehData)

		@preparedForHtml<<pt
		return true
	end
end


=begin

rawRep = File.read("rawReportTest_v2.json")
hash = JSON.parse rawRep
rep = ReportParser.new(hash, "index")
=end

#mkdir("1")



=begin
1.
 h1, 	h2
val11, val12  + инфа о том, где ссылка и имя файла-чайлда
val21, val21

2.
"" 		h1, 	h2
v1 		val11, val12  + инфа о том, где ссылка и имя файла-чайлда
v2 		val21, val22


если у val есть свойство href - его делать ссылкой со значением href.


table[l][r] = {value, href}
=end
