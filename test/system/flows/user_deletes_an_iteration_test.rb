require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class UserDeletesAnIterationTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "user deletes an iteration" do
      user = create :user
      track = create :track
      create(:user_track, user:, track:)
      exercise = create(:concept_exercise, track:)
      solution = create(:concept_solution, :published, exercise:, user:)
      submission = create(:submission, tests_status: :passed, solution:)
      create(:iteration, solution:, submission:)
      create(:submission_file, submission:)

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_iterations_url(track, exercise)
        find(".options-button").click
        click_on "Delete iteration"
        within(".m-generic-confirmation") { click_on "Delete iteration" }

        assert_text "This iteration has been deleted"
      end
    end
  end
end
