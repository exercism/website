module ReactComponents
  module Track
    class Credits < ReactComponent
      initialize_with :top_count, :top_label, :avatar_urls, bottom_count: nil, bottom_label: nil, max: 2

      def to_s
        super("track-credits", {
          top_count:,
          top_label:,
          bottom_count:,
          bottom_label:,
          max:,
          avatar_urls:

        }
        )
      end
    end
  end
end
