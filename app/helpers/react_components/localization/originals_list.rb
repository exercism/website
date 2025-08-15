module ReactComponents
  module Localization
    class OriginalsList < ReactComponent
      initialize_with :originals

      def to_s
        super(
          "localization-originals-list",
          {
            originals:,
            links: {
              localization_originals_path: Exercism::Routes.localization_originals_path,
              endpoint: Exercism::Routes.api_localization_originals_path
            }
          }
        )
      end
    end
  end
end
