require File.expand_path('gembuilder')

Gem::Specification.new do |s|
  s.name        = 'talkshow'
  s.version     = $version
  s.date        = $date
  s.summary     = 'Talkshow library'
  s.description = 'Framework for executing automated commands on TV and similar devices'
  s.authors     = ['Joseph Haig']
  s.email       = 'joe.haig@bbc.co.uk'
  s.files       = [
                    'lib/talk_show.rb',
                    'lib/talk_show_server.rb',
                  ]
  s.homepage    = 'https://github.com/fmtvp/talkshow'
  s.license     = 'Apache 2'

  s.add_runtime_dependency 'sinatra'
  s.add_runtime_dependency 'thin'
  s.add_runtime_dependency 'sinatra-contrib'
  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'cucumber'
  s.add_runtime_dependency 'watir-webdriver'
  s.add_runtime_dependency 'rspec'
end
