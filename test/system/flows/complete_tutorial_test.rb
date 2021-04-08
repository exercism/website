require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class CompleteTutorialTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "completes the tutorial succesfully" do
      track = create :track
      hello_world = create :concept_exercise, track: track, slug: "hello-world"
      user = create :user
      create :user_track, user: user, track: track
      solution = create :concept_solution, user: user, exercise: hello_world
      submission = create :submission, solution: solution
      create :iteration, submission: submission

      sign_in!(user)

      use_capybara_host do
        visit track_exercise_url(track, hello_world)

        click_on "Mark as complete"
        find("label", text: "Yes, I'd like to share my solution with the community.").click
        click_on "Confirm"
        assert_text "Tutorial complete"
      end
    end
  end
end
