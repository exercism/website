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
            tag_options: tag_options
          }
        )
      end

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
