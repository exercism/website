module ReactComponents
  module Settings
    class GithubSyncerForm < ReactComponent
      def to_s
        super("settings-github-syncer-form", {
          is_user_connected: current_user.github_solution_syncer.present?,
          is_user_active: current_user.github_solution_syncer&.enabled?,
          repo_full_name: current_user.github_solution_syncer&.repo_full_name?,
          is_user_insider: current_user.insider?,
          links: {
            connect_to_github: "https://github.com/apps/exercism-solutions-syncer/installations/new",
            settings: Exercism::Routes.settings_github_syncer_path
          }
        })
      end
    end
  end
end
