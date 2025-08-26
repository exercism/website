module ReactComponents
  module Modals
    class ExternalLanguageSelectorModal < ReactComponent
      def to_s
        return if current_user

        super("external-language-selector-modal", {
          something: 'value'
        })
      end
    end
  end
end
