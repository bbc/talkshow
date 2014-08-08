#
# Scenario 1
#

When(/^I send a window reload instruction$/) do
  @ts.invoke('window.location.reload', [], -1)
  # Small sleep to simulate reload in phantomjs
  sleep 1
end

Then(/^talkshow should continue when the window reloads$/) do
  expect(@ts.invoke('Math.sqrt', [25])).to eq 5
end

