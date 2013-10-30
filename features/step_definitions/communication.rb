$: << '.'
require 'open-uri'
require 'watir-webdriver'
require 'lib/talk_show'


Given(/^I'm running a javascsript application$/) do

  if !$test_application_pid
    $test_application_pid = fork do
      puts "Subprocess"
      Dir.chdir 'test_application'
      exec 'ruby start_app.rb > test_application.log 2>&1'
      sleep 1
    end
  end
  
end

Given(/^it's instrumented with talkshow$/) do
  puts "Sub process " + $test_application_pid.to_s

  @js_app = "http://localhost:4568/app?talkshowhost=localhost:4567"

  if !$application_ready
    # We have a predefined target, so don't run capybara
    if ENV['TARGET']
      STDERR.puts "Navigate browser to " + @js_app
      STDERR.puts "...... ready?"
      gets
    else
      driver = Selenium::WebDriver.for :phantomjs
      driver.navigate.to( @js_app )
      sleep 2
    end
    $application_ready = true
  end
  
end

Given(/^a talkshow server is running$/) do
  if !$ts
    $ts = TalkShow.new()
    $ts.start_server
  end
  @ts = $ts
end


#
# Scenario 1
#

When(/^I send a simple command$/) do
  @result = @ts.execute( 'Date.now()' )
end

Then(/^I should receive a response$/) do
  # Get the time from the running javascript. It should be
  # greater than 1374089428804 which is the result I got when
  # I wrote this test
  @result.to_i.should > 1374089428804
end


#
# Scenario 2
#

When(/^I send invalid javascript$/) do
  begin
    @ts.execute('nosuchfunction()')
  rescue Exception => e
    @exception = e
    puts e.inspect
  end
end

Then(/^I should receive an exception$/) do
  /ReferenceError/.match(@exception.to_s).should_not be_nil
end


#
# Scenario 3
#

When(/^I execute a js file$/) do
  @expected = 5
  @result = @ts.execute_file( './features/fixtures/simple.js' )
end

Then(/^I should receive the return response$/) do
  @result.to_i.should == @expected
end

#
# Scenario 4
#

When(/^I execute a multiline js file$/) do
  @expected = 2000
  @result = @ts.execute_file( './features/fixtures/multiline.js' )
end


#
# Kill off the test application if one was started
#

at_exit do
  if $test_application_pid
    puts "killing " + $test_application_pid.to_s
    Process.kill 'HUP', $test_application_pid
    Process.wait $test_application_pid
  end
end
