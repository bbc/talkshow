require 'sinatra/base'
require 'net/http'
require 'thread'
require 'json'
require 'logger'

require 'talkshow/server'
require 'thread'



class Talkshow
  class Talkshow::WebControl < Sinatra::Base

    set :bind, '0.0.0.0'
    configure do
      set :port, ENV['WEB_CONTROLLER_PORT']
    end

    # Thread safe
    def self.port_requests(queue = nil)
      if queue
        @@port_requests = queue
      end
      @@port_requests
    end

    # Read-only, not thread safe
    def self.processes(hash)
      if hash
        @@processes = hash
      end
      @@processes
    end
    
    
    def logger
      if !@logger
        @logger = Logger.new('talkshow_webcontrol.log')
      end
      @logger
    end
    
    get '/' do
      
      process_table = "<table>"
      @@processes.each do |port, status|
        process_table += "<tr><td>#{port}</td><td>#{status}</td></tr>"
      end
      process_table += "</table>"
      
      <<HERE
<html>
<style>
html { height: 100%;}
body {background: #CCC; font-family: Arial, Helvetica, sans-serif; padding: 20px;}
</style>  
  <body>
    <div>
      <h1>Talkshow web control</h1>
      <h2>PID: #{$$}</h2>
      <h2>Port: #{settings.port}</h2>
    </div>
    <div>
    <h2>Active Processes</h2>
    #{process_table}
    </div>
  </body>
</html>
HERE
    end
    
    get '/port/:port' do
      port = params[:port].to_i
      if port > 4000
        Talkshow::WebControl.port_requests.push(port)
      end
    end
    
    get '/status' do
      200
    end
    
  end
end
