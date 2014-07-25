When(/^I request to pull back an insanely large object$/) do
  begin
    @response = @ts.execute( 'a=[]; a[1000]="end"; a' )
    p @response
  rescue Talkshow::Timeout => e
    @exception = e
  end
end

Then(/^the talkshow javascript should chunk the response$/) do
  expect(@exception).to be_nil
end

Then(/^the ruby code should should reassemble it$/) do
  expect(@response).to be_a String
end
