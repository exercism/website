class SerializeMentorSessionRequest
  include Mandate

  initialize_with :request, :user

  def call
    return if request.blank?

    {
      uuid: request.uuid,
      comment: SerializeMentorDiscussionPost.(Mentor::RequestComment.from(request), user),
      is_locked: request.locked?,
      locked_until:,
      student: {
        handle: request.student_handle,
        avatar_url: request.student_avatar_url
      },
      track: {
        title: request.track.title
      },
      links: {
        lock: Exercism::Routes.lock_api_mentoring_request_path(request),
        extend_lock: Exercism::Routes.extend_lock_api_mentoring_request_path(request.uuid),
        cancel: Exercism::Routes.cancel_api_mentoring_request_path(request),
        discussion: Exercism::Routes.api_mentoring_discussions_path
      }
    }
  end

  def locked_until
    Mentor::RequestLock.find_by(request_id: request.id)&.locked_until
  end
end
