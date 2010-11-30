require 'spec_helper'
require 'crypto'

describe "Signup Confirmations" do
  before(:each) do
    @user = User.new(
      :name => "Example User",
      :username => 'exampleuser',
      :email => 'user@example.com',
      :password => 'foobar'
    )
  end

  context "when user signs up" do
    it "should be emailed to the user who just signed up" do
      expect {
        integration_signup( @user )
      }.to change(EMAILS, :size).by(1)
    end

    context "when user does not activate account" do
      it "should prevent the user from signing in" do
        integration_signup( @user )
        integration_signin( @user )

        flash[:error].should_not be_blank
        response.should contain( "Sign in" )
      end
    end

    context "when user activates account" do
      before(:each) do
        integration_signup( @user )
        integration_confirm_signup
      end

      it "should sign in the user" do
        flash[:success].should =~ /welcome/i
        response.should contain( "Sign out" )
      end

      it "should expire the token used to activate account" do
        integration_confirm_signup
        flash[:notice].should_not be_blank
        response.should contain( "Sign in" )
      end
    end
  end

  private

    def integration_signup( user )
      visit signup_path
      fill_in "Name", :with => user.name
      fill_in "Username", :with => user.username
      fill_in "Email", :with => user.email
      fill_in "Password", :with => user.password
      fill_in "Confirmation", :with => user.password
      click_button
    end

    def integration_confirm_signup
      visit confirmation_url_from_email
    end

    def confirmation_url_from_email
      email_body.match( confirm_user_path(token) )[0]
    end

    def email_body
      EMAILS.last.body.encoded
    end

    def token
      Crypto.encrypt( "#{ User.last.id }" )
    end
end