module ReactComponents
  module Localization
    class OriginalsShow < ReactComponent
      initialize_with :original

      def to_s
        super("localization-originals-show", {
          original:,
          current_user_id: current_user&.id
        })
      end
    end
  end
end
