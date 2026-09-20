module ReactComponents
  module Settings
    class LanguageForm < ReactComponent
      def to_s
        super("settings-language-form", {
          languages:,
          default_locale: current_user.locale.presence || I18n.default_locale.to_s,
          links: {
            update: Exercism::Routes.api_settings_language_url
          }
        })
      end

      private
      def languages
        I18n.available_locales.map do |locale|
          name = Locale::Name.(locale)
          { code: locale.to_s, native: name.native, english: name.english }
        end
      end
    end
  end
end
