module ReactComponents
  module Track
    class Approaches < ReactComponent
      initialize_with :videos, :introduction, :links, :track, :exercise
      def to_s
        super("track-approaches", { videos:, introduction:, links:, track:, exercise: })
      end
    end
  end
end
