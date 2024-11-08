module ReactComponents
  module Settings
    class BootcampAffiliateForm < ReactComponent
      def to_s
        super("settings-bootcamp-affiliate-form", {
          preferences:,
          insiders_status: current_user.insiders_status,
          links: {
            update: Exercism::Routes.api_settings_user_preferences_url,
            insiders_path: Exercism::Routes.insiders_path
          }
        })
      end

      def preferences = current_user.preferences.slice(:hide_website_adverts)
    end
  end
end
