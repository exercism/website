module ReactComponents
  module Settings
    class ProfileForm < ReactComponent
      extend Mandate::Memoize

      def to_s
        super("settings-profile-form",
          { user:, profile:, languages:, coming_soon_languages:, default_locale:, links: })
      end

      private
      def user
        {
          name: current_user.name,
          location: current_user.location,
          bio: current_user.bio,
          seniority: current_user.seniority
        }
      end

      def default_locale = current_user.locale.presence || I18n.default_locale.to_s

      def links
        {
          update: Exercism::Routes.api_settings_url,
          update_language: Exercism::Routes.api_settings_language_url
        }
      end

      def languages = grouped_languages[:live].map { |language| language_props(language) }
      def coming_soon_languages = grouped_languages[:coming_soon].map { |language| language_props(language) }

      memoize
      def grouped_languages = Locale::Languages.(default_locale)

      def language_props(language)
        {
          code: language.code,
          native: language.native,
          english: language.english,
          flag_url: view_context.image_path("flags/3x2/#{language.flag}.svg")
        }
      end

      def profile
        return if current_user.profile.blank?

        {
          twitter: current_user.profile.twitter,
          github: current_user.profile.github,
          linkedin: current_user.profile.linkedin
        }
      end
    end
  end
end
