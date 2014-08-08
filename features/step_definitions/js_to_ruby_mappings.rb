#
# Scenario 1
#

When(/^a number is sent from the javascript side$/) do
  @result1 = @ts.execute('1+2')
  @result2 = @ts.execute('1/2')
end

Then(/^a Numeric should be received on the ruby side$/) do
  @result1.should be_a Fixnum
  @result2.should be_a Float
end

#
# Scenario 2
#

When(/^a boolean is sent from the javascript side$/) do
  @result = @ts.execute('1==2')
end

Then(/^a TrueClass or FalseClass is received on the ruby side$/) do
  @result.class.should == FalseClass
end
