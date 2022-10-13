module ReactComponents
  module Track
    class Credits < ReactComponent
      initialize_with :top_count, :top_label, :avatar_urls

      def to_s
        super("track-credits", {
          top_count:,
          top_label:,
          avatar_urls:
        }
        )
      end
    end
  end
end
