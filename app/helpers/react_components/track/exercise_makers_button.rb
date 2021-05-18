module ReactComponents
  module Track
    class ExerciseMakersButton < ReactComponent
      initialize_with :exercise

      def to_s
        return if num_authors.zero? && num_contributors.zero?

        super("track-exercise-makers-button", {
          authors: exercise.authors.order("RAND()").limit(3).map do |author|
            {
              handle: author.handle,
              avatar_url: author.avatar_url
            }
          end,
          num_authors: num_authors,
          num_contributors: num_contributors,
          links: {
            makers: Exercism::Routes.api_track_exercise_makers_url(exercise.track, exercise)
          }
        })
      end

      memoize
      def num_authors
        exercise.authors.count
      end

      memoize
      def num_contributors
        exercise.contributors.count
      end
    end
  end
end
