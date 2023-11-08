class SerializeMentorRequests
  include Mandate

  initialize_with :requests, :mentor

  def call
    eager_loaded_requests.map { |r| serialize_request(r) }
  end

  private
  def serialize_request(request)
    relationship = relationships[request.student_id]
    had_mentoring_previously = students_who_have_had_mentoring.include?(request.student_id)
    status = "First timer" unless had_mentoring_previously
    tooltip_url = Exercism::Routes.api_mentoring_student_path(request.student, track_slug: request.track_slug)

    {
      uuid: request.uuid,

      track: {
        title: request.track_title
      },
      exercise: {
        icon_url: request.exercise_icon_url,
        title: request.exercise_title
      },

      student: {
        handle: request.student_handle,
        avatar_url: request.student_avatar_url
      },

      solution: {
        uuid: request.solution.uuid
      },

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
  def eager_loaded_requests
    requests.includes(:exercise, :track, :student, :solution).to_a
  end

  memoize
  def relationships
    Mentor::StudentRelationship.where(mentor:, student_id: requests.map(&:student_id)).
      index_by(&:student_id)
  end

  memoize
  # TODO: Could we just use fulfilled non-private requests?
  def students_who_have_had_mentoring
    Mentor::Discussion.joins(:solution).
      where('solutions.user_id': requests.map(&:student_id)).
      pluck(:user_id).uniq # Don't use DISTINCT in SQL
  end
end
