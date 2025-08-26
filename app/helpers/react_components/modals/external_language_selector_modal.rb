module ReactComponents
  module Modals
    class ExternalLanguageSelectorModal < ReactComponent
      def to_s
        return if current_user

        super("external-language-selector-modal", {
          supported_locales: I18n.available_locales
        })
      end
    end
  end
end
