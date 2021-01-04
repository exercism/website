module ReactComponents
  module Mentoring
    class Queue < ReactComponent
      def initialize(request = default_request)
        super()

        @request = request
      end

      def to_s
        super(
          "mentoring-queue",
          {
            request: request,
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
      attr_reader :request

      def default_request
        { endpoint: Exercism::Routes.api_mentor_requests_path }
      end
    end
  end
end
