class SerializeCommunitySolution
  include Mandate

  initialize_with :solution

  def call
    {
      uuid: solution.uuid,
      snippet: solution.snippet,
      num_views: solution.num_views,
      num_stars: solution.num_stars,
      num_comments: solution.num_comments,
      representation_num_published_solutions: solution.published_exercise_representation&.num_published_solutions,
      num_iterations: solution.num_iterations,
      num_loc: solution.num_loc.presence, # Currently this column is not-null in production
      iteration_status: solution.iteration_status,
      published_iteration_head_tests_status: solution.published_iteration_head_tests_status.to_s.to_sym,
      published_at: solution.published_at,
      is_out_of_date: solution.out_of_date?,
      language: track.highlightjs_language,
      author: {
        handle: user.handle,
        avatar_url: user.avatar_url,
        flair: user.flair
      },
      exercise: {
        title: solution.exercise.title,
        icon_url: solution.exercise.icon_url
      },
      track: {
        title: track.title,
        icon_url: track.icon_url,
        highlightjs_language: track.highlightjs_language
      },
      links: {
        public_url: Exercism::Routes.published_solution_url(solution),
        private_iterations_url: Exercism::Routes.track_exercise_iterations_url(track, solution.exercise)
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
