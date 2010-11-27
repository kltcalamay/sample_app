require 'spec_helper'

describe "DirectMessages" do
  before(:each) do
    @sender = Factory(:user, :username => 'sender', :email => 's@x.com')
    @recipient = Factory(:user, :username => 'recipient', :email => 'r@x.com')
    @direct_message = "this is a private message"

    integration_signin @sender
    post_micropost "d recipient " + @direct_message
    click_link 'Sign out'
  end

  it "should appear at the sender's sent messages page" do
    integration_signin @sender
    click_link "Direct Messages"
    click_link "Sent Items"
    response.should contain(@direct_message)
  end

  it "should appear at the recipient's received messages page" do
    integration_signin @recipient
    click_link "Direct Messages"
    response.should contain(@direct_message)
  end

  it "should not appear at the sender's received messages page" do
    integration_signin @sender
    visit received_direct_messages_path
    response.should_not contain(@direct_message)
  end

  it "should not appear at the recipient's sent messages page" do
    integration_signin @recipient
    visit sent_direct_messages_path
    response.should_not contain(@direct_message)
  end

  it "should not appear at the user's feed" do
    integration_signin @sender
    visit root_path
    response.should_not contain(@direct_message)
  end
end
