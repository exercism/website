class SerializeCommunitySolution
  include Mandate

  initialize_with :solution

  def call
    {
      id: solution.uuid,
      snippet: solution.snippet,
      num_views: solution.num_views,
      num_stars: solution.num_stars,
      num_comments: solution.num_comments,
      num_iterations: solution.num_iterations,
      num_loc: solution.num_loc,
      published_at: solution.published_at,
      language: track.highlightjs_language,
      author: {
        handle: user.handle,
        avatar_url: user.avatar_url
      },
      exercise: {
        title: solution.exercise.title,
        icon_url: solution.exercise.icon_url
      },
      track: {
        title: track.title,
        icon_url: solution.track.icon_url
      },
      links: {
        public_url: Exercism::Routes.published_solution_url(solution),
        private_url: Exercism::Routes.private_solution_url(solution)
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
