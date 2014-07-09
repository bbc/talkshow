talkshow
=========

Talkshow is a lightweight communications bridge for driving javascript applications
from ruby code. There are two parts to the implementation:
* Javascript talkshow library
* Ruby talkshow gem

Start by adding the talkshow.js library to your application. Ensure that talk_show
is instantiated at an appropriate point in your application lifecycle -- when the
application has loaded up for example. Instantiate the Talkshow object and
call initialize:

    ts = new Talkshow(hosturl);
    ts.initialize;
    
Add the talkshow gem to your Gemfile, and in your ruby code:

    require 'talkshow'
    ts = Talkshow.new
    ts.start_server

You can execute raw javascript, or invoke javascript methods in your application:

    ts.execute( 'alert("Hello world")')
    ts.invoke( 'Math.sqrt', [1] )

## Changing the talkshow port

You can specify an alternative port to start the talkshow server with the TALKSHOW_PORT
environment variable. For example if you are running cucumber tests with talkshow:

    TALKSHOW_URL=1234 bundle exec cucumber
    
This will tell talkshow to start up the talkshow sinatra server on port 1234.

# Testing

The main testsuite is a cucumber suite. Install phantomjs before you run
the following:

    bundle install
    bundle exec cucumber

# Running the demo

You can run the proof of concept demo if you check out the source code.

Start the test application:

    cd $TALKSHOW/test_application
    bundle install
    bundle exec ruby ./start_app.rb

Open a browser and visit <http://localhost:4568/app?talkshowhost=localhost:4567>

In a new terminal, start the Talkshow demo:

    cd $TALKSHOW
    bundle install
    RUBYLIB='./lib' ruby bin/demo.rb
