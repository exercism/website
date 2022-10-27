module ReactComponents
  module Common
    class Credits < ReactComponent
      initialize_with :users, :top_count, :top_label, :bottom_count, :bottom_label, css_class: nil

      def to_s
        super("common-credits", {
          users:,
          top_count:,
          top_label:,
          bottom_count:,
          bottom_label:
        }, css_class:)
      end
    end
  end
end
