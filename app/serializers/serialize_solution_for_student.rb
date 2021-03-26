class SerializeSolutionForStudent
  include Mandate

  initialize_with :solution

  def call
    {
      id: solution.uuid,
      url: Exercism::Routes.private_solution_url(solution),
      status: solution.status, # TODO: This is probably going to cause n+1s
      mentoring_status: solution.mentoring_status,
      has_notifications: true, # TODO
      num_views: 1270, # TODO
      num_stars: 10, # TODO
      num_comments: 2, # TODO
      num_iterations: 3, # TODO
      num_locs: "9 - 18", # TODO
      num_mentoring_comments: 2, # TOOD

      published_at: solution.published_at&.iso8601,
      completed_at: solution.completed_at&.iso8601,

      # TODO: Cache the ones of these that create n+1s
      last_submitted_at: solution.submissions.last&.created_at&.iso8601,
      has_mentor_discussion_in_progress: solution.mentor_discussions.in_progress.any?,
      has_mentor_request_pending: solution.mentor_requests.pending.any?,
      # These are already guarded against n+1s in the wider serializer
      exercise: {
        slug: solution.exercise.slug,
        title: solution.exercise.title,
        icon_url: solution.exercise.icon_url
      },
      track: {
        slug: solution.track.slug,
        title: solution.track.title,
        icon_url: solution.track.icon_url
      }
    }
  end
end
