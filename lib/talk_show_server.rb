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
    content_type 'text/javascript'
    t = Time.new()
    id = rand(99999)
    
    content = TalkShowServer.question_queue.pop if !TalkShowServer.question_queue.empty?
    type = ( content ? "code" : "nop")
    
    logger.info( "/question ##{id}: #{content}" )
    
    json = {
      :id => id,
      :time => t.to_s,
      :content => content,
      :type => type
    }.to_json
    
    "ts.handleTalkShowHostQuestion( #{json} );"
  end

  get '/answer/:poll_id/:id/:status/:data' do
    content_type 'text/javascript'
    if params[:status] != 'nop'
      TalkShowServer.answer_queue.push( {
                                          :data => params[:data],
                                          :status => params[:status]
                                         } )
    end
    logger.info( "/answer   ##{params[:id]}: #{params[:data]}" )

    "notify('nop received', true, true);"
  end

  
end
