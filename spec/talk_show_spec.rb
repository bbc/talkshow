require 'talk_show'
require 'open-uri'
require 'json'

describe "Talkshow" do

  before(:each) do
    @ts = TalkShow.new()
    @ts.start_server
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

end
