class SerializeMentorSessionRequest
  include Mandate

  initialize_with :request

  def call
    return if request.blank?

    {
      id: request.uuid,
      comment: request.comment_html,
      updated_at: request.updated_at.iso8601,
      is_locked: request.locked?,
      student: {
        handle: request.user.handle,
        avatar_url: request.user.avatar_url
      },
      track: {
        title: request.track.title
      },
      links: {
        lock: Exercism::Routes.lock_api_mentoring_request_path(request),
        discussion: Exercism::Routes.api_mentoring_discussions_path
      }
    }
  end
end
