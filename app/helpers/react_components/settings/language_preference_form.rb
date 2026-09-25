module ReactComponents
  module Settings
    class LanguagePreferenceForm < ReactComponent
      extend Mandate::Memoize

      def to_s
        super("settings-language-preference-form",
          { languages:, coming_soon_languages:, default_locale:, links: })
      end

      private
      def default_locale = current_user.locale.presence || I18n.locale.to_s

      def links = { update: Exercism::Routes.api_settings_language_url }

      def languages = grouped_languages[:live].map { |language| language_props(language) }
      def coming_soon_languages = grouped_languages[:coming_soon].map { |language| language_props(language) }

      memoize
      def grouped_languages = Locale::Languages.(default_locale)

      def language_props(language)
        {
          code: language.code,
          native: language.native,
          english: language.english,
          flag_url: view_context.image_path("flags/3x2/#{language.flag}.svg"),

          # A locale in the path outranks the saved preference.
          redirect_path: Locale::SwapInPath.(view_context.request.fullpath, language.code)
        }
      end
    end
  end
end
