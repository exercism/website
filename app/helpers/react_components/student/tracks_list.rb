module ReactComponents
  module Student
    class TracksList < ReactComponent
      # TODO: Remove `user` and its usage here once API supports session requests
      def initialize(user, tracks, request = default_request)
        super()

        @user = user
        @tracks = tracks
        @request = request
      end

      def to_s
        super(
          "student-tracks-list", {
            request: request.deep_merge(
              {
                options: {
                  initialData: {
                    tracks: SerializeTracks.(tracks, current_user)
                  }
                },
                query: {}
              }
            ),
            status_options: STATUS_OPTIONS,
            tag_options: tag_options
          }
        )
      end

      STATUS_OPTIONS = [
        { value: "all", label: "All", aria_label: "Click to see all of Exercism's tracks" },
        { value: "joined", label: "Joined", aria_label: "Click to see the tracks you have joined" },
        { value: "unjoined", label: "Unjoined", aria_label: "Click to see the tracks you have not joined" }
      ].freeze
      private_constant :STATUS_OPTIONS

      private
      attr_reader :user, :tracks, :request

      def default_request
        { endpoint: Exercism::Routes.api_tracks_path }
      end

      def tag_options
        ::Track::TAGS.map do |category, options|
          {
            category: ::Track::CATGEORIES[category],
            options: options.map do |value, label|
              { value: "#{category}/#{value}", label: label }
            end
          }
        end
      end
    end
  end
end
