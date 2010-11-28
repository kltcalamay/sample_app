require "spec_helper"

describe UserMailer do
  describe "#follower_notification(followed, follower)" do
    before(:each) do
      @follower = Factory(:user, :email => "fr@example.com", :username => "fr")
      @followed = Factory(:user, :email => "fd@example.com", :username => "fd")
    end

    it "should have the right recipient" do
      email = UserMailer.follower_notification(@followed, @follower)
      email.to.should == [ @followed.email ]
    end

    it "should have the right subject" do
      email = UserMailer.follower_notification(@followed, @follower)
      email.subject.should eq("Follower notification")
    end
  end
end
