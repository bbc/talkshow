When(/^an empty string is returned by the js$/) do
  @result = @ts.execute('""')
end

Then(/^I should receive ruby empty string$/) do
  @result.should == ''
end

When(/^a forward slash is returned in a string$/) do
  @result = @ts.execute('"Hello/everyone"')
end

Then(/^it should appear in the ruby string$/) do
  @result.class.should == String
  @result.should == 'Hello/everyone'
end
