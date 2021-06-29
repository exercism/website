module ReactComponents
  module Settings
    class ResetAccountButton < ReactComponent
      def to_s
        super("settings-reset-account-button", {
          handle: current_user.handle,
          links: {
            reset: Exercism::Routes.reset_temp_user_url
          }
        })
      end
    end
  end
end
