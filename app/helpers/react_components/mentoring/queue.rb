module ReactComponents
  module Mentoring
    class Queue < ReactComponent
      extend Mandate::Memoize

      def initialize(mentor, request = default_request)
        super()

        @mentor = mentor
        @request = request
      end

      def to_s
        super(
          "mentoring-queue",
          {
            request: request,
            tracks: track_data,
            exercises: exercise_data,
            sort_options: SORT_OPTIONS
          }
        )
      end

      SORT_OPTIONS = [
        { value: "recent", label: "Sort by Most Recent" },
        { value: "exercise", label: "Sort by Exercise" },
        { value: "student", label: "Sort by Student" }
      ].freeze
      private_constant :SORT_OPTIONS

      private
      attr_reader :mentor, :request

      def default_request
        { endpoint: Exercism::Routes.api_mentor_requests_path }
      end

      memoize
      def track_data
        Solution::MentorRequest::RetrieveTracks.(mentor)
      end

      memoize
      def exercise_data
        selected_track_slug = track_data.find { |t| t[:selected] }[:slug]
        Solution::MentorRequest::RetrieveExercises.(mentor, selected_track_slug)
      end
    end
  end
end
