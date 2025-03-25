module ReactComponents
  module Modals
    class SenioritySurveyModal < ReactComponent
      SHOWN_AT_FLAG = "shown_seniority_modal_at".freeze

      def to_s
        return if showing_modal?
        return if current_user.seniority

        showing_modal!
        session[SHOWN_AT_FLAG] = Time.current

        super(
          "modals-seniority-survey-modal",
          {
            links: {
              hide_modal_endpoint: Exercism::Routes.hide_api_settings_introducer_path(slug),
              api_user_endpoint: Exercism::Routes.api_user_url,
              coding_fundamentals_course: Courses::CodingFundamentals.url
            }
          }
        )
      end

      private
      def slug = "seniority-survey-modal"
    end
  end
end
