module ReactComponents
  module Track
    class ExerciseMakersButton < ReactComponent
      initialize_with :exercise

      def to_s
        return if num_authors.zero? && num_contributors.zero?

        super("track-exercise-makers-button", {
          avatar_urls:,
          num_authors:,
          num_contributors:,
          links: {
            makers: Exercism::Routes.api_track_exercise_makers_url(exercise.track, exercise)
          }
        })
      end

      def avatar_urls
        target = 3
        urls = exercise.authors.order("RAND()").limit(3).select(:id, :version).to_a.map(&:avatar_url)
        if urls.size < 3 && num_contributors.positive?
          urls += exercise.contributors.order("RAND()").limit(target - urls.size).select(:id, :version).to_a.map(&:avatar_url)
        end
        urls.compact
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
