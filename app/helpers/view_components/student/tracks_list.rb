module ViewComponents
  module Student
    class TracksList < ViewComponent
      TODO: Remove `user` and its usage here once API supports session requests
      def initialize(user, data, request = default_request)
        @user = user
        @data = data
        @request = request
      end

      def to_s
        react_component("student-tracks-list", {
                          request: request.deep_merge({
                                                        options: { initialData: data },
                                                        query: { auth_token: user.auth_tokens.first.to_s }
                                                      }),
                          status_options: STATUS_OPTIONS,
                          tag_options: TAG_OPTIONS
                        })
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
          options: [{ value: "Paradigm:Object-oriented", label: "Object-oriented" }]
        },
        {
          category: "Typing",
          options: [{ value: "Typing:Static", label: "Static" }, { value: "Typing:Dynamic", label: "Dynamic" }]
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
