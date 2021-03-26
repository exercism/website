module Mentor
  class Request
    class RetrieveExercises
      include Mandate

      initialize_with :mentor, :track_slug

      def call
        # TODO: Cache this using track.updated_at
        # TODO: Set track.updated_at to be touched when any exercises changes

        # Then add the order and enumerate here
        track.exercises.order(title: :asc).map do |exercise|
          {
            slug: exercise.slug,
            title: exercise.title,
            icon_url: exercise.icon_url,
            count: request_counts[exercise.id].to_i,
            completed_by_mentor: completed_by_mentor.include?(exercise.id)
          }
        end
      end

      memoize
      def track
        Track.find_by!(slug: track_slug)
      end

      memoize
      def completed_by_mentor
        mentor.solutions.
          completed.
          where(exercise: track.exercises).
          pluck(:exercise_id)
      end

      memoize
      def request_counts
        # Use the inner query for this
        Mentor::Request::Retrieve.(
          mentor: mentor,
          track_slug: track.slug,
          sorted: false, paginated: false
        ).group('solutions.exercise_id').
          count
      end
    end
  end
end
