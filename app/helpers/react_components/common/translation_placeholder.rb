module ReactComponents
  module Common
    class TranslationPlaceholder < ReactComponent
      initialize_with :locale
      def to_s
        super("common-translation-placeholder", { locale: })
      end
    end
  end
end
