class SerializeSolutionsForStudent
  include Mandate

  initialize_with :solutions

  def call
    solutions.map { |s| serialize_solution(s) }
  end

  def serialize_solution(solution)
    {
      id: solution.uuid,
      url: Exercism::Routes.private_solution_url(solution),
      status: solution.status, # TODO: This is probably going to cause n+1s
      mentoring_status: solution.mentoring_status,
      num_views: 1270, # TODO
      num_stars: 10, # TODO
      num_comments: 2, # TODO
      num_iterations: 3, # TODO
      num_locs: "9 - 18", # TODO
      last_submitted_at: solution.submissions.last&.created_at&.iso8601,
      published_at: solution.published_at&.iso8601,
      exercise: {
        title: solution.exercise.title,
        icon_name: solution.exercise.icon_name
      },
      track: {
        title: solution.track.title,
        icon_name: solution.track.icon_name
      }
    }
  end
end
