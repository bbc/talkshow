Given(/^a remote talkshow server is running$/) do
  if !$ts
    $ts = Talkshow.new
    $ts.start_server('http://localhost:4567')
  end
  @ts = $ts
end

