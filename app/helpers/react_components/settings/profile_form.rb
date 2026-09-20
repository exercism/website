module ReactComponents
  module Settings
    class ProfileForm < ReactComponent
      def to_s
        super("settings-profile-form", { user:, profile:, languages:, default_locale:, links: })
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

      def languages
        I18n.available_locales.map do |locale|
          name = Locale::Name.(locale)
          { code: locale.to_s, native: name.native, english: name.english }
        end
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
