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
    sleep 2
  end

  # Stop the webserver
  def stop_server
    # Slow down polling to a crawl
    self.execute( 'ts.nextPoll = 5000;' )
    
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
  def execute( command )
    @question_queue.push( command )
    sleep(1)

    answer = nil
    t = 0.1
    catch(:done) do
      7.times { |i|
        answer = soft_pop
        throw :done if answer
        sleep t
        t*=2
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

end

