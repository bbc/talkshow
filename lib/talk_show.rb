require 'net/http'
require 'thread'
require 'json'
require 'logger'
require_relative 'talk_show_server.rb'

class TalkShowTimeout < StandardError
end

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
    #@question_queue.push( {
    #    type: "config",
    #    message: "nextPoll=5000"
    #  } )
    
    @thread.exit
    #puts "Closed down server"
  end

  def soft_pop
    begin
      @answer_queue.pop(true)
    rescue
      nil
    end
  end

  # Send a javascript instruction to the client
  # ts.execute( 'alert("Annoying popup");' )
  def execute( command, timeout=6 )
    #logger.info( "Next command" )
    #@question_queue.push( command )
    #logger.info( "Command sent: #{command}" )
    @question_queue.push( {
                           type: 'code',
                           message: command
                          } )

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
      bool = ( answer[:data] == 'true' )
        return bool
      when 'undefined'
        if answer[:data] == 'undefined'
          nil
        else
          answer[:data]
        end
      when 'string'
      answer[:data].to_s
      else
      answer[:data]
    end
  end
  
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

