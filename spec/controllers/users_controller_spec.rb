require 'spec_helper'
require 'crypto'

describe UsersController do
  render_views

  describe "GET 'index'" do

    describe "for non-signed-in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    end

    describe "for signed-in users" do

      before(:each) do
        @user = test_sign_in(Factory(:user))
        second = Factory(:user, :email => "ex@mple.com", :username => "u2")
        third  = Factory(:user, :email => "ex@mple.net", :username => "u3")

        @users = [@user, second, third]
        30.times do
          @users << Factory(:user, :email => Factory.next(:email),
            :username => Factory.next(:username))
        end
      end

      it "should be successful" do
        get :index
        response.should be_success
      end

      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "All users")
      end

      it "should have an element for each user" do
        get :index
        @users.each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end

      it "should have an element for each user" do
        get :index
        @users[0..2].each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end

      it "should paginate users" do
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a", :href => "/users?page=2",
          :content => "2")
        response.should have_selector("a", :href => "/users?page=2",
          :content => "Next")
      end
    end
  end

  describe "GET 'show'" do

    before(:each) do
      @user = Factory(:user)
    end

    it "should find the right user" do
      get :show, :id => @user.username
      assigns(:user).should == @user
    end

    it "should have the right title" do
      get :show, :id => @user.username
      response.should have_selector("title", :content => @user.name)
    end

    it "should include the user's name" do
      get :show, :id => @user.username
      response.should have_selector("h1", :content => @user.name)
    end

    it "should have a profile image" do
      get :show, :id => @user.username
      response.should have_selector("h1>img", :class => "gravatar")
    end

    it "should show the user's microposts" do
      mp1 = Factory(:micropost, :user => @user, :content => "Foo bar")
      mp2 = Factory(:micropost, :user => @user, :content => "Baz quux")
      get :show, :id => @user.username
      response.should have_selector("span.content", :content => mp1.content)
      response.should have_selector("span.content", :content => mp2.content)
    end

    it "should have a link to the feed of the current user being shown" do
      get :show, :id => @user.username
      response.should have_selector("a",
        :href => feed_user_path(@user, :format => :rss))
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end

    it "should have the right title" do
      get 'new'
      response.should have_selector("title", :content => "Sign up")
    end
  end

  describe "POST 'create'" do

    describe "failure" do

      before(:each) do
        @attr = { :name => "", :email => "", :password => "",
          :password_confirmation => "" }
      end

      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end

      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector("title", :content => "Sign up")
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end
    end

    describe "success" do

      before(:each) do
        @attr = { :name => "New User", :email => "user@example.com",
          :password => "foobar", :password_confirmation => "foobar",
          :username => 'newuser'}
      end

      it "should create a user in an inactive state" do
        lambda do
          post :create, :user => @attr
          User.first.state.should == "inactive"
        end.should change(User, :count).by(1)
      end

      it "should tell the user to confirm their account" do
        post :create, :user => @attr
        flash[:notice].should =~ /check your email/i
      end

      it "should not sign in the user" do
        post :create, :user => @attr
        controller.should_not be_signed_in
      end

      it "should send a signup confirmation email" do
        expect {
          post :create, :user => @attr
        }.to change(EMAILS, :size).by(1)
      end

      it "should redirect to the home page" do
        post :create, :user => @attr
        response.should redirect_to( root_url )
      end
    end
  end

  describe "GET 'edit'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    it "should be successful" do
      get :edit, :id => @user.username
      response.should be_success
    end

    it "should have the right title" do
      get :edit, :id => @user.username
      response.should have_selector("title", :content => "Edit user")
    end

    it "should have a link to change the Gravatar" do
      get :edit, :id => @user.username
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravatar_url,
        :content => "change")
    end
  end

  describe "PUT 'update'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    describe "failure" do

      before(:each) do
        @attr = { :email => "", :name => "", :password => "",
          :password_confirmation => "" }
      end

      it "should render the 'edit' page" do
        put :update, :id => @user.username, :user => @attr
        response.should render_template('edit')
      end

      it "should have the right title" do
        put :update, :id => @user.username, :user => @attr
        response.should have_selector("title", :content => "Edit user")
      end
    end

    describe "success" do

      before(:each) do
        @attr = { :name => "New Name", :email => "user@example.org",
          :password => "barbaz", :password_confirmation => "barbaz"}
      end

      it "should change the user's attributes" do
        put :update, :id => @user.username, :user => @attr
        @user.reload
        @user.name.should  == @attr[:name]
        @user.email.should == @attr[:email]
      end

      it "should redirect to the user show page" do
        put :update, :id => @user.username, :user => @attr
        response.should redirect_to(user_path(@user.username))
      end

      it "should have a flash message" do
        put :update, :id => @user.username, :user => @attr
        flash[:success].should =~ /updated/
      end
    end
  end

  describe "authentication of edit/update pages" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "for non-signed-in users" do

      it "should deny access to 'edit'" do
        get :edit, :id => @user.username
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'update'" do
        put :update, :id => @user.username, :user => {}
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed-in users" do

      before(:each) do
        wrong_user = Factory(:user, :email => "user@example.net",
          :username => "wrong_user")
        test_sign_in(wrong_user)
      end

      it "should require matching users for 'edit'" do
        get :edit, :id => @user.username
        response.should redirect_to(root_path)
      end

      it "should require matching users for 'update'" do
        put :update, :id => @user.username, :user => {}
        response.should redirect_to(root_path)
      end
    end
  end

  describe "DELETE 'destroy'" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "as a non-signed-in user" do
      it "should deny access" do
        delete :destroy, :id => @user.username
        response.should redirect_to(signin_path)
      end
    end

    describe "as a non-admin user" do
      it "should protect the page" do
        test_sign_in(@user)
        delete :destroy, :id => @user.username
        response.should redirect_to(root_path)
      end
    end

    describe "as an admin user" do

      before(:each) do
        admin = Factory(:user, :email => "admin@example.com",
          :username => "admin", :admin => true)
        test_sign_in(admin)
      end

      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user.username
        end.should change(User, :count).by(-1)
      end

      it "should redirect to the users page" do
        delete :destroy, :id => @user.username
        response.should redirect_to(users_path)
      end
    end
  end

  describe "follow pages" do

    describe "when not signed in" do

      it "should protect 'following'" do
        get :following, :id => 1
        response.should redirect_to(signin_path)
      end

      it "should protect 'followers'" do
        get :followers, :id => 1
        response.should redirect_to(signin_path)
      end
    end

    describe "when signed in" do

      before(:each) do
        @user = test_sign_in(Factory(:user))
        @other_user = Factory(:user, :email => Factory.next(:email),
          :username => Factory.next(:username))
        @user.follow!(@other_user)
      end

      it "should show user following" do
        get :following, :id => @user.username
        response.should have_selector("a", :href => user_path(@other_user),
          :content => @other_user.name)
      end

      it "should show user followers" do
        get :followers, :id => @other_user.username
        response.should have_selector("a", :href => user_path(@user),
          :content => @user.name)
      end
    end
  end

  describe "GET 'confirm'" do
    before(:each) do
      @user = Factory(:user)
    end

    it "should activate the user's account" do
      get :confirm, :id => Crypto.encrypt( "#{@user.id}" )
      @user.reload.state.should == "active"
    end
  end

  describe "GET 'feed'" do
    before(:each) do
      @user = Factory(:user)
      
    end

    it "should show an rss feed with 10 microposts of the user in question" do
      11.times { |i| @user.microposts.create!(:content => "micropost #{i+1}") }
      get :feed, :id => @user.username, :format => :rss

      10.times do |n|
        # search for contents "micropost 11" to "micropost 2" because
        # micropost is queried from the latest (i.e. micropost 11)
        response.should have_selector("title", :content => "micropost #{n+2}")
      end
      # response should not contain the earliest micropost (i.e. micropost 1)
      response.should_not contain(/^micropost 1$/)
    end

    it "should be accessible even if the user is not logged in" do
      get :feed, :id => @user.username, :format => :rss
      response.should_not redirect_to(signin_path)
    end
  end
end
