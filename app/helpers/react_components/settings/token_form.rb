module ReactComponents
  module Settings
    class TokenForm < ReactComponent
      def to_s
        super("settings-token-form", {
          token: current_user.auth_token,
          links: {
            reset: Exercism::Routes.reset_api_settings_auth_token_url,
            info: Exercism::Routes.doc_url(:using, "solving-exercises/working-locally")
          }
        })
      end
    end
  end
end
