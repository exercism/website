module ReactComponents
  module Student
    class RequestMentoringButton < ReactComponent
      def initialize(track)
        super()

        @track = track
      end

      def to_s
        super(
          "student-request-mentoring-button",
          {
            request:,
            links: {
              mentor_request: Exercism::Routes.new_track_exercise_mentor_request_path("$TRACK_SLUG", "$EXERCISE_SLUG")
            }
          }
        )
      end

      private
      attr_reader :track

      def request
        {
          endpoint: Exercism::Routes.api_track_solutions_for_mentoring_index_url(track),
          query: {},
          options: {}
        }
      end
    end
  end
end
