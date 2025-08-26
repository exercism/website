module ReactComponents
  module Settings
    class LocalizationForm < ReactComponent
      def to_s
        super(
          'settings-localization-form',
          {
            user_language: :en,
            supported_languages: I18n.available_locales,
            links: { update: Exercism::Routes.api_user_url }
          }
        )
      end
    end
  end
end
