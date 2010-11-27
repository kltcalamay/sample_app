require 'spec_helper'

describe "Replies" do
  before(:each) do
    @sender = Factory(:user)
    @recipient = Factory(:user, :email => 'x@mpl.com', :username => 'recipient')
    @reply = "@#{@recipient.username} sample reply"
  end

  it "should appear at the sender's feed" do
    integration_signin(@sender)
    post_micropost(@reply)
    response.should have_selector("span.content", :content => @reply)
  end

  it "should appear at the recipients' feed" do
    integration_signin(@sender)
    post_micropost(@reply)
    click_link "Sign out"

    integration_signin(@recipient)
    click_link "Home"
    response.should have_selector("span.content", :content => @reply)
  end
end