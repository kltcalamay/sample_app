require 'spec_helper'
require 'crypto'

describe "PasswordReminders" do
  before do
    @user = Factory(:user)
  end

  it "should give users the ability to change password once per token" do
    expect {
      request_password_reminder_for( @user.username )
    }.should change(EMAILS, :size).by(1)

    email_body.should match( token )

    # use token to change password for the first time
    click_recovery_url
    submit_new_password
    flash[:success].should_not be_blank

    # use token to change password for the second time
    click_recovery_url
    flash[:error].should_not be_blank
  end

  private

    def email_body
      EMAILS.last.body.encoded
    end

    def token
      @token ||= Crypto.encrypt( "#{@user.username}:#{@user.salt}" )
    end

    def request_password_reminder_for( username )
      visit new_password_reminder_path
      fill_in "Username", :with => username
      click_button
    end

    def click_recovery_url
      visit email_body.match( reset_password_reminder_path(token) )[0]
    end

    def submit_new_password
      password = "newpassword"
      fill_in "Password", :with => password
      fill_in "Confirmation", :with => password
      click_button
    end
end
