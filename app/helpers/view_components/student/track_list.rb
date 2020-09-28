module ViewComponents
  module Student
    class TrackList < ViewComponent
      initialize_with :data, :request

      def status_options
        [
          { value: "all", label: "All" },
          { value: "joined", label: "Joined" },
          { value: "unjoined", label: "Unjoined" }
        ]
      end

      def to_s
        react_component("student-track-list", {
                          request: request.deep_merge({ options: { initialData: data } }),
                          status_options: status_options
                        })
      end
    end
  end
end
