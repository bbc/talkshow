Gem::Specification.new do |s|
  s.name        = 'talkshow'
  s.version     = '1.0.pre3'
  s.date        = $date
  s.summary     = 'Talkshow ruby gem'
  s.description = 'Ruby to Javascript communications bridge'
  s.authors     = ['Joseph Haig', 'David Buckhurst', 'Jenna Brown']
  s.email       = 'joe.haig@bbc.co.uk'
  s.files       = [
                    'lib/talkshow.rb',
                    'lib/talkshow/*',
                  ]
  s.homepage    = 'https://github.com/fmtvp/talkshow'
  s.license     = 'Apache 2'

  s.add_runtime_dependency 'sinatra'
  s.add_runtime_dependency 'sinatra-contrib'
  s.add_runtime_dependency 'thin'
  s.add_runtime_dependency 'json'
end
