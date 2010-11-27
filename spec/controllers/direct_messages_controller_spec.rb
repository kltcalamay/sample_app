require 'spec_helper'

describe DirectMessagesController do
  render_views

  before(:each) do
    @sender = Factory(:user, :username => 'sndr', :email => "s@example.com")
    @recipient = Factory(:user, :username => 'rcpnt', :email => "r@example.com")

    @direct_messages = []
    3.times do |n|
      @direct_messages << DirectMessage.create!(:sender => @sender,
        :recipient => @recipient, :content => "Message no. #{n+1}")
    end
  end

  describe "GET 'sent'" do
    it "should query all messages sent by user" do
      test_sign_in @sender
      get :sent
      assigns(:direct_messages).should == @direct_messages
    end
  end

  describe "GET 'received'" do
    it "should query all messages received by user" do
      test_sign_in @recipient
      get :received
      assigns(:direct_messages).should == @direct_messages
    end
  end

end
