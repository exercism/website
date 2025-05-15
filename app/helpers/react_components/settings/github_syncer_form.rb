module ReactComponents
  module Settings
    class GithubSyncerForm < ReactComponent
      def to_s
        super("settings-github-syncer-form", {})
      end

      def preferences = current_user.preferences.slice(:hide_website_adverts)
    end
  end
end
