require 'spec_helper'

describe "LayoutLinks" do

  it "should have a Home page at '/'" do
    get '/'
    response.should have_selector('title', :content => "Home")
  end

  it "should have a Contact page at '/contact'" do
    get '/contact'
    response.should have_selector('title', :content => "Contact")
  end

  it "should have an About page at '/about'" do
    get '/about'
    response.should have_selector('title', :content => "About")
  end

  it "should have a Help page at '/help'" do
    get '/help'
    response.should have_selector('title', :content => "Help")
  end

  it "should have a signup page at '/signup'" do
    get '/signup'
    response.should have_selector('title', :content => "Sign up")
  end

  describe "when not signed in" do
    it "should have a signin link" do
      visit root_path
      response.should have_selector("a", :href => signin_path,
                                         :content => "Sign in")
    end
  end

  describe "when signed in" do

    before(:each) do
      @user = Factory(:user)
      visit signin_path
      fill_in :email,    :with => @user.email
      fill_in :password, :with => @user.password
      click_button
    end

    it "should have a signout link" do
      visit root_path
      response.should have_selector("a", :href => signout_path,
                                         :content => "Sign out")
    end

    it "should have a profile link" do
      visit root_path
      response.should have_selector("a", :href => user_path(@user),
                                         :content => "Profile")
    end

    it "should have a direct_messages link" do
      visit root_path
      response.should have_selector("a", :href => received_direct_messages_path,
                                         :content => "Direct Messages")
    end

    context "within Direct Messages link" do

      it "should have a 'Sent Items' link" do
        visit root_path
        click_link "Direct Messages"
        response.should have_selector("a", :href => sent_direct_messages_path,
                                           :content => "Sent Items")
      end

      # visit "Sent Items" first to make "Received Items" a hyperlink
      it "should have a 'Received Items' link" do
        visit root_path
        click_link "Direct Messages"
        click_link "Sent Items"
        response.should have_selector("a", :href => received_direct_messages_path,
                                           :content => "Received Items")
      end
    end
  end
end
