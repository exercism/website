module ReactComponents
  module Student
    class RequestMentoringButton < ReactComponent
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
      def request
        {
          endpoint: Exercism::Routes.api_solutions_url,
          query: {
            # TODO: Update API to accept arrays
            status: "published",
            mentoring_status: "none",
            per_page: 5
          }
        }
      end
    end
  end
end
