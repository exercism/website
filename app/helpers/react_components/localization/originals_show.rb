module ReactComponents
  module Localization
    class OriginalsShow < ReactComponent
      initialize_with :original

      def to_s
        super("localization-originals-show", {
          original:
        })
      end
    end
  end
end
