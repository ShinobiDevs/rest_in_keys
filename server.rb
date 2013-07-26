require 'webrick'
require 'gdbm'
require 'etc'

server = WEBrick::HTTPServer.new :Port => 8000, :DocumentRoot => Dir.pwd

trap 'INT' do 
  server.shutdown 
end

gdbm = GDBM.new("#{Etc.systmpdir}/restdb.db")

server.mount_proc '/' do |req, res|
  key = req.path.split("/").first.to_s.downcase
  case req.request_method.downcase
  when "get"
    res.body = gdbm[key]
  when "post"
    val = req.path.split("/").last.to_s.downcase
    if val.blank?
      res.code = 422
      res.body = "missing value"
    else
      gdbm[key] = val
      res.code = 200
      res.body = "OK"
    end
  when "put"
  when "delete"
  else
  end
end

server.start