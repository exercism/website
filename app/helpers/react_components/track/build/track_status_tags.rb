module ReactComponents
  module Track
    class Build::TrackStatusTags < ReactComponent
      initialize_with :tags, :solution_counts
      def to_s
        super("track-build-track-status-tags", {
          tags:,
          solution_counts:,
          editor: current_user.maintainer?
        })
      end
    end
  end
end
