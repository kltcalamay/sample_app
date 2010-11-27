class DirectMessagesController < ApplicationController
  def sent
    @direct_messages = DirectMessage.where(["sender_id = ?", current_user])
  end

  def received
  end

end
