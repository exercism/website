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
            tracks: tracks,
            exercises: exercises,
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

      def tracks
        [
          {
            slug: "csharp",
            title: "C#",
            iconUrl: "https://assets.exercism.io/tracks/ruby-hex-white.png",
            count: 52
          },
          {
            slug: "ruby",
            title: "Ruby",
            iconUrl: "https://assets.exercism.io/tracks/ruby-hex-white.png",
            count: 52
          }
        ]
      end

      def exercises
        [
          {
            slug: "zipper",
            title: "Zipper",
            iconUrl: "https://assets.exercism.io/tracks/ruby-hex-white.png",
            count: 52
          }
        ]
      end
    end
  end
end
