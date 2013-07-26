require 'webrick'
require 'gdbm'
require 'etc'

server = WEBrick::HTTPServer.new :Port => 8000, :DocumentRoot => Dir.pwd

trap 'INT' do 
  server.shutdown 
end

gdbm = GDBM.new("#{Etc.systmpdir}/restdb.db")

server.mount_proc '/' do |req, res|
  path = req.path[1..-1]
  key, val = path.split("/").collect(&:to_s).collect(&:downcase)
  case req.request_method.downcase
  when "get"
    res.body = gdbm[key].to_s
  when "post"
    if key == ""
      res.status = 422
    else
      gdbm[key] = val
      res.status = 201
    end
  end
end

server.start