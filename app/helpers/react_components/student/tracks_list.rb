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
      attr_reader :user, :data, :request

      def default_request
        { endpoint: Exercism::Routes.api_tracks_path }
      end

      def tag_options
        ::Track::TAGS.map do |category, options|
          category_prefix = category.to_s.underscore.tr(" ", "_")
          {
            category: category,
            options: options.map do |value, label|
              { value: "#{category_prefix}/#{value}", label: label }
            end
          }
        end
      end
    end
  end
end
