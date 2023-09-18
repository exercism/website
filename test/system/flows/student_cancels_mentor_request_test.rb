require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/redirect_helpers"

module Flows
  class StudentCancelsMentorRequestTest < ApplicationSystemTestCase
    include CapybaraHelpers
    include RedirectHelpers

    test "student cancels mentor request" do
      user = create :user
      solution = create(:concept_solution, user:)
      request = create(:mentor_request, solution:)
      submission = create(:submission, solution:)
      create(:iteration, solution:, submission:)

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_mentor_request_path(solution.track, solution.exercise, request)
        click_on "Cancel Request"
        within(".m-generic-confirmation") { click_on "Cancel mentoring request" }

        wait_for_redirect
        assert_link "Submit for code review"
      end
    end
  end
end
