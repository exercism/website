class BootcampChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "bootcamp_chat_#{params[:solution_uuid]}"
  end
end
