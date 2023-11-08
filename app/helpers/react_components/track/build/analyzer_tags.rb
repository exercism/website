module ReactComponents
  module Track
    class Build::AnalyzerTags < ReactComponent
      initialize_with :tags, :solution_counts, :track_slug
      def to_s
        super("track-build-analyzer-tags", {
          tags: combined_tags,
          editor: current_user&.maintainer?,
          endpoints: {
            filterable: Exercism::Routes.filterable_api_track_tag_path(track_slug, ':tag'),
            enabled: Exercism::Routes.enabled_api_track_tag_path(track_slug, ':tag')
          }
        })
      end

      def combined_tags
        tags.map do |tag|
          {
            tag: tag.tag,
            enabled: tag.enabled?,
            filterable: tag.filterable?,
            num_solution: solution_counts[tag.tag].to_i
          }
        end
      end
    end
  end
end
