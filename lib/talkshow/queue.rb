require "net/http"
require "uri"
require 'json'

class Talkshow::Queue
  attr_accessor :url
  
  def initialize(url)
    @uri = URI.parse(url)
    @http = Net::HTTP.new(@uri.host, @uri.port)
  end
  
  def clear
    response = @http.request(Net::HTTP::Get.new('/answerqueue/clear'))
    response
  end

  def pop(ignored)
    response = @http.request(Net::HTTP::Get.new('/answerqueue/pop'))
    object = JSON.parse(response.body, :symbolize_names => true)
    object[:message]
  end
 
  def push(obj)
    serialized_object = obj.to_json.to_s
    request = Net::HTTP::Post.new('/questionqueue/push')
    request.set_form_data( {'message' => serialized_object } )
    response = @http.request(request)
    nil
  end
  
end