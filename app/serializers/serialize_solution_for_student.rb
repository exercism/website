class SerializeSolutionForStudent
  include Mandate

  initialize_with :solution

  def call
    {
      solution: {
        id: solution.uuid,
        url: Exercism::Routes.private_solution_url(solution),
        status: status,
        mentoring_status: solution.mentoring_status,
        num_views: 1270, # TODO
        num_stars: 10, # TODO
        num_comments: 2, # TODO
        num_iterations: 3, # TODO
        num_locs: "9 - 18", # TODO
        last_submitted_at: solution.submissions.last.try(&:created_at),
        published_at: solution.published_at,
        exercise: {
          title: solution.exercise.title,
          icon_name: solution.exercise.icon_name
        },
        track: {
          title: track.title,
          icon_name: solution.track.icon_name
        }
      }
    }
  end

  memoize
  def track
    solution.exercise.track
  end

  def status
    return :published if solution.published?
    return :completed if solution.completed?

    :started
  end
end
