#! /usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'sinatra/reloader'
require 'json'

set :port, 4568
set :bind, '0.0.0.0'

puts `cp ../js/talkshow.js public/ 2>&1`

get '/app' do
talkshowhost = params[:talkshowhost]
"""
<!DOCTYPE html>
<html lang='en'>
  <head>
    <meta charset='utf-8'>
    <title>talkshow.js</title>
    <meta name='author' content='David Buckhurst'>
    <link href='application.css' rel='stylesheet'>
  </head>
  
  <script>
    var hosturl = '#{talkshowhost}'
  </script>

  <body>
  
    <div>
      <h1>talkshow.js</h1>
    </div>

    <div class='console'>
      <ul id='talkshowconsole'>
        <li class='current'> -> Looking for talkshowhost: <span class='talkshowhost'>#{talkshowhost}</span></strong></li>
      </ul>
    </div>

    <div id='scripts'>
      <script type='text/javascript' src='talkshow.js'></script>
      <script type='text/javascript' src='application.js'></script>
    </div>
  </body>
</html>
"""
end

get '/nop.js' do
  content_type 'text/javascript'
  t = Time.new()
"""
talkShowHostQuestion(
  {
    'id':'#{t.to_i}',
    'type': 'nop'
  }
);
"""  
end

# Very simple response for checking the mechanism works
get '/simplejson.js' do
  content_type 'text/javascript'
  t = Time.new()
<<EOS
handleTalkShowHostQuestion(
  {
    'id':'#{t.to_i}',
    'time': '#{t.to_s}',
    'content': 'notify("From TalkShowHost", true, true);',
    'type': 'code'
  }
);
EOS
end
