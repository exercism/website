class SerializeMentorSessionRequest
  include Mandate

  initialize_with :request, :user

  def call
    return if request.blank?

    {
      uuid: request.uuid,
      comment: SerializeMentorDiscussionPost.(Mentor::RequestComment.from(request), user),
      is_locked: request.locked?,
      status: request.status,
      student: {
        handle: request.student_handle,
        avatar_url: request.student_avatar_url
      },
      track: {
        title: request.track.title
      },
      links: {
        lock: Exercism::Routes.lock_api_mentoring_request_path(request),
        cancel: Exercism::Routes.cancel_api_mentoring_request_path(request),
        discussion: Exercism::Routes.api_mentoring_discussions_path
      }
    }
  end
end
