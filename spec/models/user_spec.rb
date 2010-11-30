require 'spec_helper'

describe User do

  before(:each) do
    @attr = {
      :name => "Example User",
      :username => "exampleuser",
      :email => "user@example.com",
      :password => "foobar",
      :password_confirmation => "foobar",
    }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end

  it "should require a username" do
    no_username_user = User.new(@attr.merge(:username => ""))
    no_username_user.should_not be_valid
  end

  it "should reject usernames that are too long" do
    long_name = "a" * 16
    long_name_user = User.new(@attr.merge(:username => long_name))
    long_name_user.should_not be_valid
  end

  it "should accept valid usernames" do
    usernames = ["uname007", "uname", "u_name", "u_name_007", "u_007_name"]
    usernames.each do |username|
      valid_username_user = User.new(@attr.merge(:username => username))
      valid_username_user.should be_valid
    end
  end

  it "should reject invalid usernames" do
    usernames = ["u name", "u-name", "uname_", "007uname", "u*name", "u)name"]
    usernames.each do |username|
      invalid_username_user = User.new(@attr.merge(:username => username))
      invalid_username_user.should_not be_valid
    end
  end

  it "should reject duplicate usernames" do
    # Put a user with given username address into the database.
    User.create!(@attr)
    user_with_duplicate_username = User.new(@attr.merge(:email => 'x@mple.com'))
    user_with_duplicate_username.should_not be_valid
  end

  it "should reject usernames identical up to case" do
    upcased_uname = @attr[:username].upcase
    User.create!(@attr.merge(:username => upcased_uname, :email => 'x@mpl.com'))
    user_with_duplicate_uname = User.new(@attr)
    user_with_duplicate_uname.should_not be_valid
  end

  it "should require an email address" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end

  it "should reject names that are too long" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
    # Put a user with given email address into the database.
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr.merge(:username => 'other'))
    user_with_duplicate_email.should_not be_valid
  end

  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email, :username => 'other'))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "should have a follower_notifications attribute" do
    User.new.should respond_to(:follower_notifications)
  end

  it "should have a state attribute" do
    User.new.should respond_to(:state)
  end

  describe "#activate!" do
    it "should change the user's state from inactive to active" do
      @user = Factory(:user)   # creates an 'active' user by default so we must
      @user.state = "inactive" # manually set user's state to inactive first
      @user.activate!
      @user.reload.state.should == "active"
    end
  end

  describe "password validations" do

    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end

    it "should require a matching password confirmation" do
      User.new(@attr.merge(:password_confirmation => "invalid")).
        should_not be_valid
    end

    it "should reject short passwords" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end

    it "should reject long passwords" do
      long = "a" * 41
      hash = @attr.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end
  end

  describe "password encryption" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    describe "has_password? method" do

      it "should be true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end    

      it "should be false if the passwords don't match" do
        @user.has_password?("invalid").should be_false
      end 
    end

    describe "authenticate method" do

      it "should return nil on email/password mismatch" do
        wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
        wrong_password_user.should be_nil
      end

      it "should return nil for an email address with no user" do
        nonexistent_user = User.authenticate("bar@foo.com", @attr[:password])
        nonexistent_user.should be_nil
      end

      it "should return the user on email/password match" do
        matching_user = User.authenticate(@attr[:email], @attr[:password])
        matching_user.should == @user
      end
    end
  end

  describe "admin attribute" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end

  describe "micropost associations" do

    before(:each) do
      @user = User.create(@attr)
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end

    it "should have a microposts attribute" do
      @user.should respond_to(:microposts)
    end

    it "should have the right microposts in the right order" do
      @user.microposts.should == [@mp2, @mp1]
    end

    it "should destroy associated microposts" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end

    describe "status feed" do

      it "should have a feed" do
        @user.should respond_to(:feed)
      end

      it "should include the user's microposts" do
        @user.feed.should include(@mp1)
        @user.feed.should include(@mp2)
      end

      it "should not include a different user's microposts" do
        mp3 = Factory(:micropost,
                      :user => Factory(:user, :email => Factory.next(:email)))
        @user.feed.should_not include(mp3)
      end

      it "should include the microposts of followed users" do
        followed = Factory(:user, :email => Factory.next(:email))
        mp3 = Factory(:micropost, :user => followed)
        @user.follow!(followed)
        @user.feed.should include(mp3)
      end
    end
  end

  describe "relationships" do

    before(:each) do
      @user = User.create!(@attr)
      @followed = Factory(:user)
    end

    it "should have a relationships method" do
      @user.should respond_to(:relationships)
    end

    it "should have a following method" do
      @user.should respond_to(:following)
    end

    it "should have a following? method" do
      @user.should respond_to(:following?)
    end

    it "should have a follow! method" do
      @user.should respond_to(:follow!)
    end

    it "should follow another user" do
      @user.follow!(@followed)
      @user.should be_following(@followed)
    end

    it "should include the followed user in the following array" do
      @user.follow!(@followed)
      @user.following.should include(@followed)
    end

    it "should have an unfollow! method" do
      @followed.should respond_to(:unfollow!)
    end

    it "should unfollow a user" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      @user.should_not be_following(@followed)
    end

    it "should have a reverse_relationships method" do
      @user.should respond_to(:reverse_relationships)
    end

    it "should have a followers method" do
      @user.should respond_to(:followers)
    end

    it "should include the follower in the followers array" do
      @user.follow!(@followed)
      @followed.followers.should include(@user)
    end
  end

  context "when mentioned by other users (i.e. @my_username)" do

    before(:each) do
      @user = Factory(:user, :username => 'my_username')
      @other = Factory(:user, :email => Factory.next(:email))
      @other.microposts.create!(:content => "@my_username what's up?")
    end

    it "should be associated with the resulting micropost" do
      @user.received_replies.should include( @other.microposts.last )
    end

    context "when this user is deleted" do
      it "should delete associations with all replies" do
        @user.destroy
        associations = Recipient.where("user_id = #{@user.id}")
        associations.should be_blank
      end
    end
  end
end
