require 'spec_helper'

describe "FollowerNotifications" do
  before(:each) do
    @follower = Factory(:user, :email => "fr@example.com", :username => "fr")
    @followed = Factory(:user, :email => "fd@example.com", :username => "fd")
  end

  context "when turned on" do
    it "should be emailed to users when someone starts following them" do
      expect {
        integration_follow(:followed => @followed, :follower => @follower)
      }.to change(EMAILS, :size).by(1)

      recipient = EMAILS.last.to
      recipient.should == [ @followed.email ]

      email_body = EMAILS.last.body.encoded
      email_body.should contain( /^#{@follower.name}(.*)following you/ )
    end
  end

  context "when turned off" do
    it "should NOT be emailed to users when someone starts following them" do
      expect {
        @followed.toggle!(:follower_notifications) # from true(default) to false
        integration_follow(:followed => @followed, :follower => @follower)
      }.to change(EMAILS, :size).by(0)
    end
  end

  private

  def integration_follow( options )
    integration_signin options[:follower]
    visit user_path( options[:followed] )
    click_button
  end
end
