require 'spec_helper'

describe DirectMessage do
  before(:each) do
    sender = Factory(:user, :username => 'sndr', :email => 's@example.com')
    recipient = Factory(:user, :username => 'rcpnt', :email => 'r@example.com')

    @attr = {:sender_id => sender.id, :recipient_id => recipient.id,
      :content => 'some content'}
  end

  it "should be valid given valid attributes" do
    DirectMessage.create!(@attr)
  end

  it "should not be valid without a sender" do
    no_sender_dm = DirectMessage.new(@attr.merge(:sender_id => nil))
    no_sender_dm.should_not be_valid
  end

  it "should not be valid without a recipient" do
    no_recipient_dm = DirectMessage.new(@attr.merge(:recipient_id => nil))
    no_recipient_dm.should_not be_valid
  end

  it "should not be valid without a content" do
    no_content_dm = DirectMessage.new(@attr.merge(:content => ""))
    no_content_dm.should_not be_valid
  end
end
