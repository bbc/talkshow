require 'net/http'
require 'thread'
require 'json'
require 'logger'
require 'lib/talk_show_server'

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
  
  # Send a javascript instruction to the client
  # ts.execute( 'alert("Annoying popup");' )
  def execute( command )
    @question_queue.push( command )
    answer = @answer_queue.pop
    
    if answer[:status] == 'error'
      raise answer[:data]
    end
    #puts "#{command} ==> #{answer[:data]}"
    answer[:data]
  end
  
  def execute_file( filename )
    text = File.read(filename)
    execute(text)
  end

  def recover
    @question_queue.push( 'ts.recover();')
  end

end

