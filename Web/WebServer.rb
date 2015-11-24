#encoding: utf-8
#encode: utf-8
require "webrick"
require "#{File.dirname(__FILE__)}/LoginForm.rb"
require "#{File.dirname(__FILE__)}/CheckLogin.rb"
require "#{File.dirname(__FILE__)}/Logout.rb"
require "#{File.dirname(__FILE__)}/Sender.rb"
require "#{File.dirname(__FILE__)}/Getter.rb"
require 'erb'

server = WEBrick::HTTPServer.new(:Port=>1000, DocumentRoot: "./")
#server.mount('/', WEBrick::HTTPServlet::ERBHandler, 'index.html')

server.mount "/", LoginForm
server.mount "/login", CheckLogin
server.mount "/logout", Logout
server.mount "/send", Sender
server.mount "/get", Getter
server.mount "/html", WEBrick::HTTPServlet::FileHandler, './html'
server.mount "/rep", WEBrick::HTTPServlet::FileHandler, './attInRange/Report'
print (IO.read("version.txt")+"\n")
server.start