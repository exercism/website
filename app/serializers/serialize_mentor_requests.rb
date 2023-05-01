class SerializeMentorRequests
  include Mandate

  initialize_with :requests, :mentor

  def call
    requests.includes(:exercise, :track, student: :avatar_attachment).
      map { |r| serialize_request(r) }
  end

  private
  def serialize_request(request)
    relationship = relationships[request.student_id]
    had_mentoring_previously = students_who_have_had_mentoring.include?(request.student_id)
    status = "First timer" unless had_mentoring_previously
    tooltip_url = Exercism::Routes.api_mentoring_student_path(request.student, track_slug: request.track_slug)

    {
      uuid: request.uuid,

      track_title: request.track_title,
      exercise_icon_url: request.exercise_icon_url,
      exercise_title: request.exercise_title,

      student_handle: request.student_handle,
      student_avatar_url: request.student_avatar_url,

      # TODO: Should this be requested_at?
      updated_at: request.created_at.iso8601,

      have_mentored_previously: !!relationship,
      is_favorited: !!relationship&.favorited?,
      status:,
      tooltip_url:,

      # TODO: Rename this to web_url
      url: Exercism::Routes.mentoring_request_url(request)
    }
  end

  memoize
  def relationships
    Mentor::StudentRelationship.where(mentor:, student_id: requests.map(&:student_id)).
      index_by(&:student_id)
  end

  memoize
  def students_who_have_had_mentoring
    Mentor::Discussion.joins(:solution).where('solutions.user_id': requests.map(&:student_id)).distinct.pluck(:user_id)
  end
end
