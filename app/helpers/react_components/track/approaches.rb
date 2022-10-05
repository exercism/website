module ReactComponents
  module Track
    class Approaches < ReactComponent
      initialize_with :videos, :introduction, :links, :track, :exercise
      def to_s
        super("track-approaches", { videos:, introduction:, links:, track: track_data, exercise: exercise_data })
      end

      def track_data
        {
          icon_url: track.icon_url,
          title: track.title,
          slug: track.slug
        }
      end

      def exercise_data
        {
          icon_url: exercise.icon_url,
          title: exercise.title
        }
      end
    end
  end
end
