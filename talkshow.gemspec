Gem::Specification.new do |s|
  s.name        = 'talkshow'
  s.version     = '1.0.pre'
  s.date        = $date
  s.summary     = 'Talkshow library'
  s.description = 'Framework for executing automated commands on TV and similar devices'
  s.authors     = ['Joseph Haig', 'David Buckhurst', 'Jenna Brown']
  s.email       = 'joe.haig@bbc.co.uk'
  s.files       = [
                    'lib/talk_show.rb',
                    'lib/talk_show_server.rb',
                  ]
  s.homepage    = 'https://github.com/fmtvp/talkshow'
  s.license     = 'Apache 2'

  s.add_runtime_dependency 'sinatra'
  s.add_runtime_dependency 'sinatra-contrib'
  s.add_runtime_dependency 'thin'
  s.add_runtime_dependency 'json'
end
