class Solution
  class MentorRequest
    class RetrieveTracks
      include Mandate

      def initialize(mentor, selected_id: nil)
        @mentor = mentor
        @selected_id = selected_id || default_selected_id
      end

      def call
        mentored_tracks.map do |track|
          {
            slug: track.slug,
            title: track.title,
            icon_url: track.icon_url,
            count: request_counts[track.id].to_i,
            selected: track.id == selected_id,
            links: {
              exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: track.slug)
            }
          }
        end
      end

      private
      attr_reader :mentor, :selected_id

      memoize
      def completed_by_mentor
        mentor.solutions.
          completed.
          where(exercise: exercises).
          pluck(:exercise_id)
      end

      memoize
      def request_counts
        Solution::MentorRequest::Retrieve.(
          mentor,
          sorted: false, paginated: false
        ).joins(solution: :exercise).
          group('exercises.track_id').
          count
      end

      memoize
      def default_selected_id
        # TODO: Record last mentored track as the preference
        # and use it here
        mentored_tracks.first.id
      end

      memoize
      def mentored_tracks
        # TODO: Set this to just the tracks someone mentors
        ::Track.order(title: :asc).to_a
      end
    end
  end
end
