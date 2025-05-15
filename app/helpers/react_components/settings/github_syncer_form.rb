module ReactComponents
  module Settings
    class GithubSyncerForm < ReactComponent
      def to_s
        super("settings-github-syncer-form", {
          is_user_connected: true,
          is_user_active: false,
          links: {
            connect_to_github: "https://github.com/apps/exercism-solutions-syncer/installations/new",
            settings: Exercism::Routes.settings_github_solution_syncer_path
          }
        })
      end
    end
  end
end
