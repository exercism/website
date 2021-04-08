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
            request: request,
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
          endpoint: Exercism::Routes.api_solutions_url,
          query: {
            track_id: track.slug,
            status: %i[iterated completed published],
            mentoring_status: %i[none finished],
            per_page: 5
          }
        }
      end
    end
  end
end
