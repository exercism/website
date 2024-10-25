module ReactComponents
  module Modals
    class SenioritySurveyModal < ReactComponent
      def to_s
        return if current_user.introducer_dismissed?(slug)

        super(
          "modals-seniority-survey-modal",
          {
            endpoint: Exercism::Routes.hide_api_settings_introducer_path(slug)
          }
        )
      end

      private
      def slug
        "seniority-survey-modal"
      end
    end
  end
end
