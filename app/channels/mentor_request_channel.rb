class MentorRequestChannel < ApplicationCable::Channel
  def subscribed
    mentor_request = Mentor::Request.find_by!(uuid: params[:uuid])

    stream_for mentor_request
  end

  def unsubscribed; end

  def self.broadcast!(request)
    broadcast_to request, {
      mentor_request: {
        uuid: request.uuid,
        status: request.status
      }
    }
  end
end
