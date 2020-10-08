module ViewComponents
  module Student
    class TracksList < ViewComponent
      def initialize(data, request = default_request)
        @data = data
        @request = request
      end

      def to_s
        react_component("student-tracks-list", {
                          request: request.deep_merge({ options: { initialData: data } }),
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
      attr_reader :data, :request

      def default_request
        # TODO: Change this to the actual endpoint, not the test endpoint
        { endpoint: Exercism::Routes.tracks_test_components_student_tracks_list_path, query: {} }
      end
    end
  end
end
