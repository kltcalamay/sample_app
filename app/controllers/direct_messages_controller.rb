class DirectMessagesController < ApplicationController
  def sent
    @direct_messages = DirectMessage.where(["sender_id = ?", current_user])
  end

  def received
    @direct_messages = DirectMessage.where(["recipient_id = ?", current_user])
  end

end
