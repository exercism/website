require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class CompleteTutorialTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "completes the tutorial succesfully" do
      user = create :user
      solution = create(:hello_world_solution, user:)
      submission = create(:submission, solution:)
      create(:iteration, submission:)
      create :user_track, user:, track: solution.track

      use_capybara_host do
        sign_in!(user)

        visit track_exercise_url(solution.track, solution.exercise)

        click_on "Mark as complete"
        find("label", text: "Yes, I'd like to share my solution with the community.").click
        click_on "Confirm"
        sleep(1)
        assert_text "You’ve completed “Hello, World!”"

        click_on "Return to “Hello, World!”"
        sleep(1)
        assert_text "You've completed Hello, World!"
      end
    end
  end
end
