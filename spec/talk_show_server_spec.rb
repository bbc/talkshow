require 'talk_show'
require 'open-uri'
require 'json'

describe "Talkshow" do

  before(:each) do
    @question_queue = Queue.new
    @answer_queue = Queue.new
    @thread = Thread.new do
      TalkShowServer.question_queue(@question_queue)
      TalkShowServer.answer_queue(@answer_queue)
      TalkShowServer.run!()
    end
    sleep 3
  end

  it "should start the server" do
    data = open('http://localhost:4567/talkshowhost').read
    data.should eq('Talkshow running on localhost')
  end

  it "should return questions with the requested callback" do
    data = open('http://localhost:4567/question/123?callback=test_callback_function').read
    data.should start_with('test_callback_function(')
    data.should end_with(');')
  end

  it "should return JSON for questions without a callback" do
    expect {
      JSON.parse(open('http://localhost:4567/question/123').read)
    }.to_not raise_error
  end

  it "should return answers with the requested callback" do
    data = open('http://localhost:4567/answer/123/456/status/object/content?callback=test_callback_function').read
    data.should start_with('test_callback_function(')
    data.should end_with(');')
  end

  it "should return 'ok' to answers without a callback" do
    data = open('http://localhost:4567/answer/123/456/status/object/content').read
    data.should eq('ok')
  end

  it "should give information about the question type" do
    type = 'message type'
    message = "alert('hello')"
    @question_queue.push({type: type, message: message})
    json = JSON.parse(open('http://localhost:4567/question/123').read)
    json.should have_key("type")
    json["type"].should eq(type)
  end

  it "should serve up the message" do
    type = 'message type'
    message = "alert('hello')"
    @question_queue.push({type: type, message: message})
    json = JSON.parse(open('http://localhost:4567/question/123').read)
    json.should have_key("content")
    json["content"].should eq(message)
  end

end
