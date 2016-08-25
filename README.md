talkshow
=========

Talkshow is a lightweight communications bridge for driving javascript applications
from ruby code. It's useful for when you're using a browser that doesn't support
selenium or other methods of automation. We use it at the BBC to automate our TAL 
TV applications.

There are two parts to the implementation:
* Javascript talkshow library
* Ruby talkshow gem

Start by adding the talkshow.js library to your application. Ensure that talk_show
is instantiated at an appropriate point in your application lifecycle -- when the
application has loaded up for example. Instantiate the Talkshow object and
call initialize:

    ts = new Talkshow(hosturl);
    ts.initialize;
    
The hosturl is the url of the talkshow server that you will start in a moment.

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

    TALKSHOW_PORT=1234 bundle exec cucumber
    
This will tell talkshow to start up the talkshow sinatra server on port 1234.

## Using a remote talkshow instance

If you would rather start the talkshow server as a seperate process you can start a seperate talkshow server as follows:

    TALKSHOW_PORT=4570 ./bin/talkshow_server.rb

You can tell your test code to use that talkshow rather than starting talkshow in a thread: 

    export TALKSHOW_REMOTE_URL='http://localhost:4570'

Or you can specify the remote url in your code when you start the server: ts.start_server( 'http://localhost:4570' )

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
    
# Running all three applications (web_app, proxying server, talkshow client)

1. Run the /proxying server/ on localhost 4570 - 
    
    TALKSHOW_PORT=4570 ./bin/talkshow_server.rb

2. Run the test /web_app/ (the app that simulates an app running on TVs) on localhost:4568

    ~/workspace/talkshow/test_applications/bundle exec ruby start_app.rb

3. Browse to this URL to connect the web_app with the proxying server, then keep this URL open in a browser: http://localhost:4568/app?talkshowhost=localhost:4570

4. Open an irb shell for the /talkshow client/ in the root of talkshow bundle: 

    ~/workspace/talkshow/bundle exec irb
    
5. Use the following to run the talkshow client and connect it to the proxying serer:

    require 'talkshow'
    ts = Talkshow.new
    ts.start_server("http://localhost:4570")

6. In the irb shell, run the following:

    ts.execute("console.log("test");")

7. Return to the browser window displaying the web_app, open the javascript console and you should see the "test" message logged to the js console.

## License

Talkshow is part of the BBC Hive project and available to everyone under the terms of the MIT open source licence.
Take a look at the LICENSE file in the code.

Copyright (c) 2016 BBC
