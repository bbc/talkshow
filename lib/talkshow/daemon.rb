require 'net/http'
require "uri"

require 'thread'
require 'json'
require 'daemon'

require 'talkshow'
require 'talkshow/web_control'
require 'talkshow/server'

class Talkshow::Daemon
  attr_accessor :thread
  attr_accessor :port_requests
  attr_accessor :processes
  
  # Create a new Talkshow object to get going
  def initialize
    Dir.mkdir './logs' if !Dir.exists?('./logs')
    Dir.mkdir './pids' if !Dir.exists?('./pids')
    @processes = {}
    @port_requests = ::Queue.new
  end

  def start_server
    @thread = Thread.new do
      Talkshow::WebControl.port_requests(@port_requests)
      Talkshow::WebControl.processes(@processes)
      Talkshow::WebControl.run!
    end
    p @thread
    sleep 10
  end

  # Stop the webserver
  def stop_server
    @thread.exit
  end

  def run
    self.start_server
    loop do
      deal_with_port_requests
      sleep 5
      check_processes
    end
  end

  def deal_with_port_requests
    begin
      port = @port_requests.pop(true)
    rescue
      port = nil
    end
    if port
      if @processes[port]
        puts "Port request -- checking aliveness"
        if check_status(port) == 'dead'
          @processes[port] = spawn_process(port)
        end
      else
        puts "New port request"
        @processes[port] = spawn_process(port)
      end
    end
  end
  
  def spawn_process(port)
    `TALKSHOW_PORT=#{port} bundle exec ./bin/talkshow_server.rb > logs/talkshow.#{port}.log 2>&1 &`
    sleep 5
    'starting'
  end
  
  def check_status(port)
    uri = URI.parse("http://localhost:#{port}/status")
    begin
      response = Net::HTTP.get_response(uri)
    rescue
      status = 'dead'
    end
    
    if !status
      if response.code.to_i == 200
        status = 'ok'
      else
        status = "dead #{response.code}"
      end
    end
    status
  end
  
  def check_processes()
    @processes.each do |port, status|
      @processes[port] = check_status(port)
    end
  end

end

