module ReactComponents
  module Settings
    class ChatGptForm < ReactComponent
      def to_s
        super("settings-chatgpt-api-key-form", {
          api_key: 'current api key',
          # api_key: current_user.chat_gpt_api_key,
          links: {
            update: Exercism::Routes.sudo_update_api_settings_url
          }
        })
      end
    end
  end
end
