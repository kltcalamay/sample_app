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

  it "should appear at the recipients' feed"

  private

    def integration_signin(user)
      visit '/signin'
      fill_in :email, :with => user.email
      fill_in :password, :with => user.password
      click_button
    end

    def post_micropost(content)
      visit '/'
      fill_in :micropost_content, :with => content
      click_button
    end
end