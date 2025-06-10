class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{current_user.id}"
  end
end
