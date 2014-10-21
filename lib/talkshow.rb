require 'net/http'
require 'thread'
require 'json'
require 'talkshow/server'
require 'talkshow/timeout'
require 'talkshow/javascript_error'
require 'talkshow/queue'


#Main class for talking to a talkshow instrumented js application.
#
#This is the only class you need to worry about, and there are only
#a few important methods.
#
# Create the Talkshow client object:
#   ts = Talkshow.new()
# Start up the server
#   ts.start_server()
# Start executing javascript:
#   ts.execute( 'alert "Hello world!"' )
class Talkshow
  attr_accessor :type
  attr_accessor :thread
  
  # Create a new Talkshow object to get going:
  def initialize
  end

  # Start up the Talkshow webserver
  # This will be triggered if you don't do it -- but it takes a few
  # seconds to start up the thin server, so you are better off
  # issuing this yourself
  def start_server(url = nil)

    url = ENV['TALKSHOW_REMOTE_URL'] if ENV['TALKSHOW_REMOTE_URL']
    
    if !url
      @type = :thread
      @question_queue = ::Queue.new
      @answer_queue = ::Queue.new
      @thread = Thread.new do
        Talkshow::Server.question_queue(@question_queue)
        Talkshow::Server.answer_queue(@answer_queue)
        Talkshow::Server.run!
      end
    else
      @type = :remote
      @question_queue = Talkshow::Queue.new(url)
      @answer_queue = Talkshow::Queue.new(url)
    end
    
  end

  # Stop the webserver
  def stop_server
    @thread.exit
  end

  # Invoke a function in the javascript application
  # invoke requires a function name (including the namespace).
  # Arguments are specified as an array reference.
  #
  # Some examples:
  #     ts.invoke( 'alert' )
  #     ts.invoke( 'alert', ['Hello world'])
  #     ts.invoke( 'window.alert', ['Hello world'] )
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
  
  # Load in a javascript file and execute remotely
  def execute_file( filename )
    text = File.read(filename)
    execute(text)
  end
  
  private
 
  def soft_pop
    begin
      @answer_queue.pop(true)
    rescue => e
      puts e
      nil
    end
  end
  
  def non_blocking_pop(timeout)
    sleep_time = 0.1
    answer = nil
    catch(:done) do
      (timeout/sleep_time).to_i.times { |i|
        answer = soft_pop
        throw :done if answer
        sleep sleep_time
      }
    end
    answer
  end


  # listen for an answer for a specific id, with a timeout, and also reconstitute
  # any chunked responses
  def listen_for_answer(id, timeout)
 
    if ENV['TIMEOUT_MULTIPLIER']
      timeout = ENV['TIMEOUT_MULTIPLIER'].to_i * timeout
    end

    answer = non_blocking_pop(timeout)
    if !answer
      raise Talkshow::Timeout.new
    end
    
    mismatch_retry = 3
    if answer[:id].to_i != id.to_i && mismatch_retry >= 0
      puts "Talkshow warning: message mismatch (#{answer[:id]} vs #{id})" unless answer[:id].to_i == 0
      answer = non_blocking_pop(timeout)
      mismatch_retry -= 1
    end

    if !answer
      raise Talkshow::Timeout.new
    end
    
    chunks = answer[:chunks]
    if chunks
      answers = [answer]

      i = 1
      nil_count = 0
      while ( i < chunks.to_i && nil_count < 3 ) do
        candidate = non_blocking_pop(1)
        if !candidate
          nil_count += 1
          next
        end
        if candidate[:id].to_i != id.to_i
          puts "Talkshow warning: message mismatch (#{candidate[:id]} vs #{id.to_i})"
          next
        end
        
        nil_count = 0
        i += 1
        answers << candidate
      end
      
      if answers.count < chunks.to_i
        raise "Couldn't reconstitute whole message"
      end
      
      sorted_answers = answers.sort_by{ |a| a[:payload].to_i }
      data = sorted_answers.collect { |a| a[:data] }.join
      answer[:data] = data
      answer[:payload] = nil
    end
        
    answer
  end

  
  # Send message to js application
  # Message is a hash that looks like:
  #   {
  #     type =>    message_type,
  #     message => command,
  #   }
  # Timeout is optional, but a negative timeout returns without
  # looking for an answer
  def send_question( message, timeout )
    
    # Start the server if it hasn't been started already
    self.start_server if (self.type == :thread && !self.thread)
    
    @answer_queue.clear();
    message[:id] = rand(99999)

    @question_queue.push( message )
    
    # Negative timeout - fire and forget
    # Should only be used if it is known not to return an answer
    return nil if timeout < 0

    answer = listen_for_answer(message[:id], timeout)

    if answer[:status] == 'error'
      raise Talkshow::JavascriptError.new( answer[:data] )
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
      rescue StandardError => e
        answer[:data]
      end
    end
  end

end

