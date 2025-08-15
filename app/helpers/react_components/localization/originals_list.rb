module ReactComponents
  module Localization
    class OriginalsList < ReactComponent
      initialize_with :originals

      def to_s
        super(
          "localization-originals-list",
          {
            originals:
          }
        )
      end
    end
  end
end
