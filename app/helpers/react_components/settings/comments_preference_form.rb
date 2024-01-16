module ReactComponents
  module Settings
    class CommentsPreferenceForm < ReactComponent
      def to_s
        super("settings-comments-preference-form", {
          current_preference:,
          label:,
          num_published_solutions: current_user.solutions.published.count,
          num_solutions_with_comments_enabled: current_user.solutions.published.where(allow_comments: true).count,
          links: {
            update: Exercism::Routes.api_settings_user_preferences_url,
            enable_comments_on_all_solutions: Exercism::Routes.enable_solution_comments_api_settings_user_preferences_url,
            disable_comments_on_all_solutions: Exercism::Routes.disable_solution_comments_api_settings_user_preferences_url
          }
        })
      end

      def current_preference
        current_user.preferences.allow_comments_on_published_solutions
      end

      def label = I18n.t("user_preferences.allow_comments_on_published_solutions")
    end
  end
end
