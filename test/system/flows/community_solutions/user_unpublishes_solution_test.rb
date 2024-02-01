require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/redirect_helpers"

module Flows
  module CommunitySolutions
    class UserUnpublishesSolutionTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include RedirectHelpers

      test "user unpublishes a solution" do
        track = create :track
        exercise = create(:concept_exercise, track:)
        author = create :user, handle: "author"
        create(:user_track, user: author, track:)
        solution = create(:concept_solution, :completed, :published, user: author, exercise:)
        submission = create(:submission, solution:)
        create(:iteration, idx: 1, submission:)
        submission = create(:submission, solution:)
        iteration_2 = create(:iteration, idx: 2, submission:)
        solution.update!(published_iteration: iteration_2)

        use_capybara_host do
          sign_in!(author)
          visit track_exercise_solution_url(track, exercise, "author")

          click_on "Publish settings"
          click_on "Unpublish solution…"
          within(".m-unpublish-solution") { click_on "Unpublish solution" }

          wait_for_redirect
          assert_text "Publish your Exercise"
        end
      end
    end
  end
end
