module ReactComponents
  module Track
    class ExerciseContributors < ReactComponent
      initialize_with :exercise

      def to_s
        super("track-exercise-contributors", {
          authors: exercise.authors.map do |author|
            {
              handle: author.handle,
              avatar_url: author.avatar_url
            }
          end,
          num_contributors: exercise.contributors.size,
          links: {
            contributors: Exercism::Routes.api_exercise_contributors_url(exercise)
          }
        })
      end
    end
  end
end
