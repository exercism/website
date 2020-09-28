module ViewComponents
  module Student
    class TrackList < ViewComponent
      initialize_with :data

      def to_s
        react_component("student-track-list", data)
      end
    end
  end
end
