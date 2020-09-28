module ViewComponents
  module Student
    class TrackList < ViewComponent
      initialize_with :data, :request

      def to_s
        react_component("student-track-list", {
                          request: request.deep_merge({ options: { initialData: data } })
                        })
      end
    end
  end
end
