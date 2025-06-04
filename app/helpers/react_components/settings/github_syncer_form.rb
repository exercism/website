module ReactComponents
  module Settings
    class GithubSyncerForm < ReactComponent
      def to_s
        super("settings-github-syncer-form", {
          is_user_connected: syncer.present?,
          is_user_insider: false, # current_user.insider?,
          syncer: syncer_settings,
          default_commit_message_template: User::GithubSolutionSyncer::DEFAULT_COMMIT_MESSAGE_TEMPLATE,
          default_path_template: User::GithubSolutionSyncer::DEFAULT_PATH_TEMPLATE,
          tracks:,
          links: {
            connect_to_github: "https://github.com/apps/exercism-solutions-syncer/installations/new",
            settings: Exercism::Routes.settings_github_syncer_path,
            sync_track: Exercism::Routes.sync_track_settings_github_syncer_path,
            sync_everything: Exercism::Routes.sync_everything_settings_github_syncer_path
          }
        })
      end

      private
      def syncer_settings
        return nil unless syncer

        {
          enabled: syncer.enabled?,
          repo_full_name: syncer.repo_full_name,
          sync_on_iteration_creation: syncer.sync_on_iteration_creation?,
          sync_exercise_files: syncer.sync_exercise_files?,
          processing_method: syncer.processing_method,
          main_branch_name: syncer.main_branch_name,
          commit_message_template: syncer.commit_message_template,
          path_template: syncer.path_template
        }
      end

      # for visual testing purposes, remove once this is shipped
      def mock_syncer
        {
          enabled: false,
          repo_full_name: "exercism/example-repo",
          sync_on_iteration_creation: true,
          sync_exercise_files: true,
          processing_method: "commit",
          main_branch_name: "unbroken",
          commit_message_template: User::GithubSolutionSyncer::DEFAULT_COMMIT_MESSAGE_TEMPLATE,
          path_template: User::GithubSolutionSyncer::DEFAULT_PATH_TEMPLATE
        }
      end

      def syncer = current_user.github_solution_syncer

      memoize
      def tracks
        current_user.tracks.select(:slug, :title).map do |track|
          {
            slug: track.slug,
            title: track.title,
            icon_url: track.icon_url
          }
        end
      end
    end
  end
end
