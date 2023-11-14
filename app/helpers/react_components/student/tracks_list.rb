module ReactComponents
  module Student
    class TracksList < ReactComponent
      # TODO: (Optional) Remove `user` and its usage here once API supports session requests
      def initialize(user, tracks, params)
        super()

        @user = user
        @tracks = tracks
        @params = params
      end

      def to_s
        super("student-tracks-list", { request:, tag_options: })
      end

      private
      attr_reader :user, :tracks, :params

      def request
        {
          endpoint: Exercism::Routes.api_tracks_path,
          options: {
            initial_data: {
              tracks: SerializeTracks.(tracks, user)
            }
          },
          query: {
            criteria: params[:criteria] || "",
            page: params[:page] ? params[:page].to_i : 1,
            tags: params[:tags] || []
          }
        }
      end

      def tag_options
        ::Track::TAGS.map do |category, options|
          {
            category: ::Track::CATGEORIES[category],
            options: options.map do |value, label|
              { value: "#{category}/#{value}", label: }
            end
          }
        end
      end
    end
  end
end
