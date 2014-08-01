require 'sinatra/base'
require 'net/http'
require 'thread'
require 'json'
require 'logger'


# Sinatra server that is launched by your test code
# to talk to the instrumented javascript application
class Talkshow
  class Talkshow::Server < Sinatra::Base
    
    configure do
      set :port, ENV['TALKSHOW_PORT'] if ENV['TALKSHOW_PORT']
      set :protection, except: :path_traversal
    end

    def self.question_queue(queue = nil)
      if queue
        @@question_queue = queue
      end
      @@question_queue
    end
    
    def self.answer_queue(queue = nil)
      if queue
        @@answer_queue = queue
      end
      @@answer_queue
    end
    
    
    def logger
      if !@logger
        @logger = Logger.new('talkshowserver.log')
      end
      @logger
    end
    
    # Make this available externally
    set :bind, '0.0.0.0'
    
    get '/talkshowhost' do
      "Talkshow running on " + request.host.to_s
    end
  
    get '/question/:poll_id' do
      t = Time.new()
      id = rand(99999)
  
      json_hash = {
        :id => id,
        :time => t.to_s,
      }
  
      logger.info( "question ##{id} coming in" )
  
      content = nil;
      if Talkshow::Server.question_queue.empty?
        logger.info( "Queue is empty" )
        json_hash[:type] = "nop"
        json_hash[:message] = ""
  
      else
        content = Talkshow::Server.question_queue.pop if !Talkshow::Server.question_queue.empty?
        logger.info( "content: #{content.to_s}" )
        
        type = content[:type]
        json_hash[:type] = type
            
        if type == 'code'
          json_hash[:content] = content[:message]
        elsif type == 'invocation'
          json_hash[:function] = content[:function]
          json_hash[:args] = content[:args]
        end
      end
  
      callback = params[:callback]
      
      #logger.info( "/question ##{id}: #{content}" )
  #    logger.info( "/question ##{id}: #{type}: #{message}" )
      
      json = json_hash.to_json
  
      logger.info( json )
      
      if callback
        content_type 'text/javascript'
        "#{callback}( #{json} );"
      else
        content_type :json
        json
      end
    end
  
    get '/answer/:poll_id/:id/:status/:object/:data' do
      #callback = params[:callback]
      if params[:status] != 'nop'
        Talkshow::Server.answer_queue.push( {
                                            :data    => params[:data],
                                            :object  => params[:object],
                                            :status  => params[:status],
                                            :chunks  => params[:chunks],
                                            :payload => params[:payload]
                                           } )
      end
      
      logger.info( "/answer ##{params[:id]}"+ ( params[:chunks] ? "(#{params[:payload]}/#{params[:chunks]})" : '') +": #{params[:data]}" )
      if params[:id] == 0
        logger.info( "Reset received, talkshow reloaded")
      end
      
      content_type 'text/javascript'
      'ts.ack();'
    end
  
  end
end
