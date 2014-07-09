require 'net/http'
require 'thread'
require 'json'
require 'logger'
require_relative 'talk_show_server.rb'

class TalkShowTimeout < StandardError
end


#
# Talkshow communications api for sending commands
# to talkshow.js lib running in your web application
#
class TalkShow
  
  attr_accessor :thread, :port

  def initialize( )
  end

  # Start up a webserver for managing the jsonp communication
  def start_server
    @question_queue = Queue.new
    @answer_queue = Queue.new
    @thread = Thread.new do
      TalkShowServer.question_queue(@question_queue)
      TalkShowServer.answer_queue(@answer_queue)
      TalkShowServer.run!()
    end
  end

  # Stop the webserver
  def stop_server
    # Slow down polling to a crawl
    logger.info( "resetting nextPoll" )
    self.execute( 'ts.nextPoll = 5000;' )
    
    @thread.exit
  end

  def soft_pop
    begin
      @answer_queue.pop(true)
    rescue
      nil
    end
  end


  def invoke( function, args, timeout=6 )
    send_question( {
        type: 'invocation',
        function: function,
        args: args
      }, timeout)
  end

  # Send a javascript instruction to the client
  def execute( command, timeout=6 )
    send_question( { type: 'code', message: command }, timeout)
  end
    
  def send_question( message, timeout )
    @answer_queue.clear();
    @question_queue.push( message )
    
    # Negative timeout - fire and forget
    # Should only be used if it is known not to return an answer
    return nil if timeout < 0

    sleep_time = 0.1
    answer = nil
    catch(:done) do
      (timeout/sleep_time).to_i.times { |i|
        answer = soft_pop
        throw :done if answer
        sleep sleep_time
      }
    end
    
    if !answer
      raise TalkShowTimeout.new
    end

    if answer[:status] == 'error'
      raise answer[:data]
    end

    case answer[:object]
    when 'boolean'
      answer[:data] == 'true'
    when 'number'
      if answer[:data].include?('.')
        answer[:data].to_f
      else
        answer[:data].to_i
      end
    when 'undefined'
      if answer[:data] == 'undefined'
        nil
      else
        answer[:data]
      end
    when 'string'
      answer[:data].to_s
    else
      begin
        JSON.parse(answer[:data])
      rescue
        answer[:data]
      end
    end
  end
  
  # Load in a javascript file and execute remotely
  def execute_file( filename )
    text = File.read(filename)
    execute(text)
  end

  def recover
    @question_queue.push( 'ts.recover();')
  end

  def logger
    if !@logger
      @logger = Logger.new('talkshowworker.log')
    end
    @logger
  end

end

