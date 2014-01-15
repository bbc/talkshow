require 'talk_show'
require 'open-uri'

describe "Talkshow" do

  it "should start the server" do
    @ts = TalkShow.new()
    @ts.start_server
    file = open('http://localhost:4567/talkshowhost')
    file.read.should eq('Talkshow running on localhost')
  end

end
