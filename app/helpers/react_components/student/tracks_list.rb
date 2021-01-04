module ReactComponents
  module Student
    class TracksList < ReactComponent
      # TODO: Remove `user` and its usage here once API supports session requests
      def initialize(user, data, request = default_request)
        super()

        @user = user
        @data = data
        @request = request
      end

      def to_s
        super(
          "student-tracks-list", {
            request: request.deep_merge(
              {
                options: { initialData: data },
                query: {}
              }
            ),
            status_options: STATUS_OPTIONS,
            tag_options: TAG_OPTIONS
          }
        )
      end

      STATUS_OPTIONS = [
        { value: "all", label: "All", aria_label: "Click to see all of Exercism's tracks" },
        { value: "joined", label: "Joined", aria_label: "Click to see the tracks you have joined" },
        { value: "unjoined", label: "Unjoined", aria_label: "Click to see the tracks you have not joined" }
      ].freeze
      private_constant :STATUS_OPTIONS

      TAG_OPTIONS = [
        {
          category: "Paradigm",
          options: [{ value: "paradigm/object_oriented", label: "Object-oriented" }]
        },
        {
          category: "Typing",
          options: [{ value: "typing/static", label: "Static" }, { value: "typing/dynamic", label: "Dynamic" }]
        }
      ].freeze
      private_constant :TAG_OPTIONS

      private
      attr_reader :user, :data, :request

      def default_request
        { endpoint: Exercism::Routes.api_tracks_path }
      end
    end
  end
end
