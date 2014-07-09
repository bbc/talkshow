#
# Scenario 1
#

When(/^I send a window reload instruction$/) do
  result = @ts.invoke('window.location.reload', [])
  result.should == nil
end

Then(/^talkshow should continue when the window reloads$/) do
  @ts.invoke('Math.sqrt', [25]).to_i.should == 5
end

