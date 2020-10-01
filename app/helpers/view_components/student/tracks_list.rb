module ViewComponents
  module Student
    class TracksList < ViewComponent
      initialize_with :data, :request

      def to_s
        react_component("student-tracks-list", {
                          request: request.deep_merge({ options: { initialData: data } }),
                          status_options: STATUS_OPTIONS
                        })
      end

      STATUS_OPTIONS = [
        { value: "all", label: "All" },
        { value: "joined", label: "Joined" },
        { value: "unjoined", label: "Unjoined" }
      ].freeze
      private_constant :STATUS_OPTIONS
    end
  end
end
