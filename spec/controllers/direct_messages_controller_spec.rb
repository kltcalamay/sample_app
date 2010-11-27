require 'spec_helper'

describe DirectMessagesController do
  render_views

  describe "GET 'sent'" do
    it "should be successful" do
      get 'sent'
      response.should be_success
    end
  end

  describe "GET 'received'" do
    it "should be successful" do
      get 'received'
      response.should be_success
    end
  end

end
