Given /^the XML:$/ do |string|
  @xml = string
end

When /^I generate Puppet$/ do
  @text = Puppet::Parser::Xml.to_puppet(@xml)
end

Then /^I should have an empty string$/ do
  @text.empty?.should == true
end

Then /^I should have the string:$/ do |string|
  # This is clearly a stupid check, but whatever I don't give a fuck
  @text.gsub(/\s/, '').should == string.gsub(/\s/, '')
end
