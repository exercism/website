require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Components
  module Editor
    class BugReportTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user reports a bug" do
        user = create :user
        track = create :track
        exercise = create(:concept_exercise, track:)
        create(:user_track, track:, user:)
        create(:concept_solution, user:, exercise:)

        use_capybara_host do
          sign_in!(user)
          visit edit_track_exercise_path(track, exercise)
          find(".more-btn").click
          click_on("Report a bug")
          fill_in "Please provide as much detail as possible", with: "I found a bug"
          click_on "Submit bug report"

          assert_text "Bug report submitted. Thank you!"
        end

        report = ProblemReport.last
        assert_equal exercise, report.about
        assert_equal user, report.user
        assert_equal "I found a bug", report.content_markdown
      end
    end
  end
end
