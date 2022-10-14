module ReactComponents
  module Track
    class Credits < ReactComponent
      initialize_with :avatar_urls, :top_count, :top_label, :bottom_count, :bottom_label, max: 2

      def to_s
        super("track-credits", {
          avatar_urls:,
          top_count:,
          top_label:,
          bottom_count:,
          bottom_label:,
          max:
        })
      end
    end
  end
end
