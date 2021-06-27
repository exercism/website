module ReactComponents
  module Settings
    class TokenForm < ReactComponent
      def to_s
        super("settings-token-form", {
          token: current_user.auth_token,
          links: {
            reset: Exercism::Routes.reset_api_auth_token_url,
            info: "#"
          }
        })
      end
    end
  end
end
