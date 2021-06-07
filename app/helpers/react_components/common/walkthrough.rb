module ReactComponents
  module Common
    class Walkthrough < ReactComponent
      initialize_with :user

      def to_s
        super("common-walkthrough", { html: html })
      end

      private
      CONFIGURE_COMMAND_TOKEN = "[CONFIGURE_COMMAND]".freeze
      CONFIGURE_COMMAND = "exercism configure --token=%s".freeze

      def html
        Git::WebsiteCopy.
          new.
          walkthrough.
          gsub(CONFIGURE_COMMAND_TOKEN, configure_command)
      end

      def configure_command
        format(CONFIGURE_COMMAND, auth_token)
      end

      def auth_token
        user ? user.auth_tokens.first : "[TOKEN]"
      end
    end
  end
end
