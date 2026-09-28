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
            },
            refetch_on_mount: false
          },
          query: {
            criteria: params[:criteria] || "",
            page: params[:page] ? params[:page].to_i : 1,
            tags: params[:tags] || []
          }
        }
      end

      def tag_options
        ::Track::TAGS.map do |category, values|
          {
            category: ::Track.tag_category_label(category),
            options: values.map do |value|
              tag = "#{category}/#{value}"
              { value: tag, label: ::Track.tag_label(tag) }
            end
          }
        end
      end
    end
  end
end
