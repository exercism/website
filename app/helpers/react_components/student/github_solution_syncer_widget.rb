module ReactComponents
  module Student
    class GithubSolutionSyncerWidget < ReactComponent
      initialize_with :solution

      def to_s
        super(
          "student-github-solution-syncer-widget",
          {
            links: {
              github_syncer_settings: Exercism::Routes.settings_github_syncer_path
            },
            syncer:,
            sync: {
              endpoint: Exercism::Routes.sync_solution_settings_github_syncer_path,
              body: json_body
            }
          }
        )
      end

      def json_body
        {
          track_slug: track.slug,
          exercise_slug: exercise.slug
        }.to_json
      end

      private
      delegate :exercise, :track, to: :solution

      def syncer = solution.user.github_solution_syncer
    end
  end
end
