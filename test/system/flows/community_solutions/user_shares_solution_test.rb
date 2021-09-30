require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module CommunitySolutions
    class UserSharesSolutionTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user sees share panel upon clicking share button" do
        author = create :user, handle: "author"
        exercise = create :concept_exercise
        solution = create :concept_solution, :published, exercise: exercise, user: author
        submission = create :submission, solution: solution
        create :iteration, idx: 1, solution: solution, submission: submission

        use_capybara_host do
          visit track_exercise_solution_path(exercise.track, exercise, author.handle)
          click_on "Share"

          share_url = track_exercise_solution_url(exercise.track, exercise, author.handle)
          # rubocop:disable Lint/UriEscapeUnescape
          assert_link(
            "Twitter",
            href: URI.encode(
              "https://twitter.com/intent/tweet?url=#{share_url}&title=View this solution on Exercism"
            )
          )
          # rubocop:enable Lint/UriEscapeUnescape
          assert_button share_url
        end
      end
    end
  end
end
