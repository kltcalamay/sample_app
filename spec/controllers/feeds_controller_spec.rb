require 'spec_helper'

describe FeedsController do
  render_views

  describe "GET 'private'" do
    before(:each) do
      @user = Factory(:user)
    end

    it "should return an HTTP ERROR status when token is invalid" do
      get :private, :id => 'invalid_token',
        :user_id => @user.username, :format => :rss
      response.status.should == 403 # :forbidden
    end

    it "should return an HTTP ERROR status when username is invalid" do
      get :private, :id => 'invalid_token',
        :user_id => 'invalid_username', :format => :rss
      response.status.should == 403 # :forbidden
    end

    context "when all request parameters are valid" do
      it "should return at most 10 microposts from the user's feed" do
        11.times { |n| @user.microposts.create!(:content => "micropost #{n+1}") }

        get :private, :id => @user.encrypted_password,
          :user_id => @user.username, :format => :rss

        10.times do |n|
          response.should have_selector("item title", :content => "micropost #{n+2}")
        end
        response.should_not contain(/^microposts 1$/)
      end
    end

  end
end
