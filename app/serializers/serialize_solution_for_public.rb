class SerializeSolutionForPublic
  include Mandate

  initialize_with :solution

  def call
    {
      solution: {
        id: solution.uuid,
        url: Exercism::Routes.published_solution_url(solution),
        num_views: 1270, # TODO
        num_stars: 10, # TODO
        num_comments: 2, # TODO
        num_iterations: 3, # TODO
        num_locs: "9 - 18", # TODO
        published_at: solution.published_at,
        user: {
          handle: user.handle,
          avatar_url: user.avatar_url
        },
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
  delegate :user, to: :solution

  memoize
  def track
    solution.exercise.track
  end
end
