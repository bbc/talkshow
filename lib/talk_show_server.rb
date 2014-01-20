require 'sinatra/base'
require 'net/http'
require 'thread'
require 'json'
require 'logger'

class TalkShowServer < Sinatra::Base
  
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

    content = TalkShowServer.question_queue.pop if !TalkShowServer.question_queue.empty?
    type = ( content ? "code" : "nop")

    callback = params[:callback]
    
    logger.info( "/question ##{id}: #{content}" )
    
    json = {
      :id => id,
      :time => t.to_s,
      :content => content,
      :type => type
    }.to_json
    
    if callback
      content_type 'text/javascript'
      "#{callback}( #{json} );"
    else
      content_type :json
      json
    end
  end

  get '/answer/:poll_id/:id/:status/:object/:data' do
    callback = params[:callback]
    if params[:status] != 'nop'
      TalkShowServer.answer_queue.push( {
                                          :data => params[:data],
                                          :object => params[:object],
                                          :status => params[:status]
                                         } )
    end
    logger.info( "/answer   ##{params[:id]}: #{params[:data]}" )

    if callback
      content_type 'text/javascript'
      "#{callback}( 'nop received', true, true );"
    else
      content_type 'text/html'
      'ok'
    end
  end

end
