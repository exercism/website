class BootcampChatChannel < ApplicationCable::Channel
  def subscribed
    solution = current_user.bootcamp_solutions.find_by!(uuid: params[:solution_uuid])
    stream_from "bootcamp_chat_#{solution.uuid}"
  end
end
