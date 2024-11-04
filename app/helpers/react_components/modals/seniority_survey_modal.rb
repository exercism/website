module ReactComponents
  module Modals
    class SenioritySurveyModal < ReactComponent
      def to_s
        # return if current_user.introducer_dismissed?(slug)

        super(
          "modals-seniority-survey-modal",
          {
            links: {
              hide_modal_endpoint: Exercism::Routes.hide_api_settings_introducer_path(slug),
              api_user_endpoint: Exercism::Routes.api_user_url
            }
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
