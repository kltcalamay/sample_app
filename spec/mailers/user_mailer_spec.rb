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

  describe "#password_recovery(options)" do
    before(:each) do
      @user = Factory(:user)
      @options = {
        :token => "a1Ab2Bc3C", :host => 'localhost', :email => @user.email
      }
      UserMailer.password_recovery(@options).deliver
    end

    it "should have the right recipient" do
      EMAILS.last.to.should == [ @user.email ]
    end

    it "should have the right body" do
      email_body = EMAILS.last.body.encoded
      email_body.should contain(
        "http://#{@options[:host]}#{reset_password_reminder_path(@options[:token])}")
    end
  end

  describe "#signup_confirmation(options)" do
    before(:each) do
      @user = Factory(:user)
      @options = {
        :token => "a1Ab2Bc3C", :host => 'localhost', :email => @user.email
      }
      UserMailer.signup_confirmation(@options).deliver
    end

    it "should have the right recipient" do
      EMAILS.last.to.should == [ @user.email ]
    end

    it "should have the right body" do
      email_body = EMAILS.last.body.encoded
      email_body.should contain(
        "http://#{@options[:host]}#{confirm_user_path(@options[:token])}")
    end
  end
end
