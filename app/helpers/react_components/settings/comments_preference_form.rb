module ReactComponents
  module Settings
    class CommentsPreferenceForm < ReactComponent
      def to_s
        super("settings-comments-preference-form", {
          current_preference: allow_comments_by_default,
          label:,
          links: {
            update: Exercism::Routes.api_settings_user_preferences_url
          }
        })
      end

      def allow_comments_by_default
        current_user.preferences.allow_comments_by_default || false
      end

      def label = I18n.t("user_preferences.allow_comments_by_default")
    end
  end
end
