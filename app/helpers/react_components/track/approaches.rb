module ReactComponents
  module Track
    class Approaches < ReactComponent
      initialize_with :videos, :introduction
      def to_s
        super("track-approaches", { videos:, introduction: })
      end
    end
  end
end
