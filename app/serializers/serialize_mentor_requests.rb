class SerializeMentorRequests
  include Mandate

  initialize_with :requests

  def call
    requests.includes(:user, :exercise, :track).
      map { |r| serialize_request(r) }
  end

  private
  def serialize_request(request)
    {
      # TODO: Maybe expose a UUID instead?
      id: request.uuid,

      track_title: request.track_title,
      exercise_icon_url: request.exercise_icon_url,
      exercise_title: request.exercise_title,

      mentee_handle: request.user_handle,
      mentee_avatar_url: request.user_avatar_url,

      # TODO: Should this be requested_at?
      updated_at: request.created_at.iso8601,

      # TODO: Add all these
      is_starred: true,
      have_mentored_previously: true,
      status: "First timer",
      tooltip_url: "#",

      # TODO: Rename this to web_url
      url: Exercism::Routes.mentoring_request_url(request)
    }
  end
end
