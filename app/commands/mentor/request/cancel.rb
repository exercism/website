class Mentor::Request::Cancel
  include Mandate

  initialize_with :request

  def call
    request.cancelled!
    request.locks.destroy_all
    MentorRequestChannel.broadcast!(request)
  end
end
