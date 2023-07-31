module ReactComponents
  module Settings
    class ShowOnSupportersPageButton < ReactComponent
      def to_s
        super("settings-show-on-supporters-page-button", {
          value: true,
          links: {
            update: Exercism::Routes.api_settings_url
          }
        })
      end
    end
  end
end
