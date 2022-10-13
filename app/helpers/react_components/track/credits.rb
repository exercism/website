module ReactComponents
  module Track
    class Credits < ReactComponent
      initialize_with :avatar_urls, :top_count, :top_label, :bottom_count, :bottom_label

      def to_s
        super("track-credits", {
          avatar_urls:,
          top_count:,
          top_label:,
          bottom_count:,
          bottom_label:
        }
        )
      end
    end
  end
end
