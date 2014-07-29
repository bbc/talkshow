When(/^I request to pull back an insanely large object$/) do
  begin
    @response = @ts.execute( 'a=[]; a[100000]="end"; a' )
    @ref = []; @ref[100000]="end"
  rescue Talkshow::Timeout => e
    @exception = e
  end
end

Then(/^the talkshow javascript should chunk the response$/) do
  expect(@exception).to be_nil
end

Then(/^the ruby code should should reassemble it$/) do
  expect(@response).to eq @ref
end
