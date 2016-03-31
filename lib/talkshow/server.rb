require 'sinatra/base'
require 'net/http'
require 'thread'
require 'json'
require 'logger'


class Queue
  # Take a peek at what's in the array
  def peek
    @que
  end
end

# Sinatra server that is launched by your test code
# to talk to the instrumented javascript application
class Talkshow
  class Talkshow::Server < Sinatra::Base
    
    configure do
      set :port, ENV['TALKSHOW_PORT'] if ENV['TALKSHOW_PORT']
      set :protection, except: :path_traversal
    end

    def self.set_port port
      set :port, port
    end

    def self.set_logfile file
      @@logfile = file
      @logger.close if @logger
      @logger = nil
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
        @logger = Logger.new(@@logfile || './talkshowserver.log')
      end
      @logger
    end
    
    # Make this available externally
    set :bind, '0.0.0.0'

    get '/' do
      questions = Talkshow::Server.question_queue.peek.to_json
      answers = Talkshow::Server.answer_queue.peek.to_json

      <<HERE
<html>
  <body>
    <div>
      <h1>Talkshow process: #{$$}</h1>
      <h2>Port: #{settings.port}</h2>
    </div>
    <div>
      <p>#{questions}</p>
    </div>
    <div>
      <p>#{answers}</p>
    </div>
  </body>
</html>
HERE
    end
    
    get '/status' do
      200
    end
    
    get '/talkshowhost' do
      "Talkshow running on " + request.host.to_s
    end
  
    get '/question/:poll_id' do
      t = Time.new()
  
      json_hash = {
        :time => t.to_s,
      }
  
      content = nil;
      if Talkshow::Server.question_queue.empty?
        logger.debug("question: nop")
        json_hash[:type] = "nop"
        json_hash[:message] = ""
  
      else
        content = Talkshow::Server.question_queue.pop if !Talkshow::Server.question_queue.empty?
        id = content[:id]
        json_hash[:id] = id
        logger.info( "question ##{id}: #{content.to_s}" )
        
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
 
    # Deal with an answer, push it back to the main thread 
    def handle_answer(params, data)
      if params[:status] != 'nop'
                
        Talkshow::Server.answer_queue.push( {
                                            :data    => data,
                                            :object  => params[:object],
                                            :status  => params[:status],
                                            :chunks  => params[:chunks],
                                            :payload => params[:payload],
                                            :id      => params[:id]
                                           } )
      end
      
      logger.info( "/answer ##{params[:id]}"+ ( params[:chunks] ? "(#{params[:payload].to_i+1}/#{params[:chunks]})" : '') +": #{data}" )
      if params[:id] == 0
        logger.info( "Reset received, talkshow reloaded")
      end
      
      content_type 'text/javascript'
      'ts.ack();'
    end
 
    # Capture an answer 
    get '/answer/:poll_id/:id/:status/:object/:data' do
      handle_answer(params, params[:data])
    end

    # Capture the case when a response has no data (empty string)
    get '/answer/:poll_id/:id/:status/:object/' do
      handle_answer(params, '')
    end
    
    # Capture older talkshow.js implementations that didn't escape urls properly
    get '/answer/:poll_id/:id/:status/:object/*' do
      logger.warn("WARNING: Unescaped url passed as data component for route '#{request.fullpath}'")
      data = params[:splat].join('/')
      handle_answer(params, data)
    end 

    # Functions for remotely clearing queues
    get '/answerqueue/clear' do
      Talkshow::Server.answer_queue.clear()
    end

    get '/questionqueue/clear' do
      Talkshow::Server.question_queue.clear()
    end

    # Push something onto the answer queue remotely
    post '/questionqueue/push' do
      logger.info( '/questionqueue/push' )
      message = JSON.parse(params[:message], :symbolize_names => true)
      logger.debug("Message pushed: #{message}")
      Talkshow::Server.question_queue.push(message)
    end

    # Pop something from the answer queue
    get '/answerqueue/pop' do
      logger.info('answerqueue/pop')
      begin
        message = Talkshow::Server.answer_queue.pop(true)
      rescue
        message = nil
      end
      { :message => message }.to_json
    end
    
    get '/questionqueue' do
      Talkshow::Server.question_queue.peek.to_json
    end

    get '/answerqueue' do
      Talkshow::Server.answer_queue.peek.to_json
    end

    # Catch anything else and shout about it
    get '/*' do
      puts "[Talkshow server warning] Unhandled route: '#{request.fullpath}'"
      logger.error("WARNING: Unhandled route: '#{request.fullpath}'")
    end
  
  end
end
