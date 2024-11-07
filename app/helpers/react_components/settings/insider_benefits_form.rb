module ReactComponents
  module Settings
    class InsiderBenefitsForm < ReactComponent
      def to_s
        super("settings-insider-benefits-form", {
          preferences: current_user.preferences,
          links: {
            update: Exercism::Routes.api_settings_user_preferences_url
          }
        })
      end
    end
  end
end
