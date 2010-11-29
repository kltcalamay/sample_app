require 'spec_helper'
require 'crypto'

describe PasswordRemindersController do
  render_views

  before(:each) do
    @user = Factory(:user)
    @token = Crypto.encrypt("#{@user.username}:#{@user.salt}")
  end

  describe "GET 'new'" do
    it "should have the right title" do
      get :new
      response.should have_selector('title', :content => "Recover password")
    end
  end

  describe "POST 'create'" do
    it "should redirect to '/'" do
      post :create
      response.should redirect_to( root_url )
    end

    context "when username provided exists in the database" do
      it "should assign a flash[:notice] message" do
        post :create, :username => @user.username
        flash[:notice].should_not be_blank
      end

      it "should send an email" do
        expect {
          post :create, :username => @user.username
        }.to change(EMAILS, :size).by(1)
      end
    end

    context "when username provided does not exist in the database" do
      it "should assign a flash[:error] message" do
        post :create, :username => "invalid_username"
        flash[:error].should_not be_blank
      end
    end
  end

  describe "GET 'reset'" do
    context "when the token is valid" do
      it "should signin the user" do
        get :reset, :id => @token
        controller.should be_signed_in
      end

      it "should assign a flash[:notice] message" do
        get :reset, :id => @token
        flash[:notice].should_not be_blank
      end

      it "should redirect to the 'Edit User' page" do
        get :reset, :id => @token
        response.should redirect_to( edit_user_path(@user) )
      end
    end

    context "when the token is not valid" do
      it "should not signin the user" do
        get :reset, :id => "invalid_token"
        controller.should_not be_signed_in
      end

      it "should assign a flash[:error] message" do
        get :reset, :id => "invalid_token"
        flash[:error].should_not be_blank
      end

      it "should redirect to the home page" do
        get :reset, :id => "invalid_token"
        response.should redirect_to( root_url )
      end
    end
  end
end
