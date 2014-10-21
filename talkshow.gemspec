Gem::Specification.new do |s|
  s.name        = 'talkshow'
  s.version     = '1.4.0.pre'
  s.date        = $date
  s.summary     = 'Talkshow ruby gem'
  s.description = 'Ruby to Javascript communications bridge'
  s.authors     = ['Joseph Haig', 'David Buckhurst', 'Jenna Brown']
  s.email       = 'joe.haig@bbc.co.uk'
  s.files       = [
                    'lib/talkshow.rb',
                    'lib/talkshow/daemon.rb',
                    'lib/talkshow/javascript_error.rb',
                    'lib/talkshow/queue.rb',
                    'lib/talkshow/server.rb',
                    'lib/talkshow/timeout.rb',
                    'lib/talkshow/web_control.rb',
                  ]
  s.homepage    = 'https://github.com/fmtvp/talkshow'
  s.license     = 'MIT'

  s.add_runtime_dependency 'sinatra'
  s.add_runtime_dependency 'thin'
  s.add_runtime_dependency 'json'
end

