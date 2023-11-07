module ReactComponents
  module Track
    class Build::TrackStatusTags < ReactComponent
      initialize_with :tags, :solution_counts
      def to_s
        super("track-build-track-status-tags", {
          tags: combined_tags,
          editor: current_user.maintainer?
        })
      end

      def combined_tags
        tags.map do |tag|
          {
            tag: tag.tag,
            enabled: tag.enabled?,
            filterable: tag.filterable?,
            num_solution: solution_counts[tag.tag]
          }
        end
      end
    end
  end
end
