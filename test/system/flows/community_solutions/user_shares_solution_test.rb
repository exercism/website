require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/uri_encode_helpers"

module Flows
  module CommunitySolutions
    class UserSharesSolutionTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include UriEncodeHelpers

      test "user sees share panel upon clicking share button" do
        Exercism.stubs(:share_platforms).returns([:twitter])
        author = create :user, handle: "author"
        exercise = create :concept_exercise
        solution = create :concept_solution, :published, exercise:, user: author
        submission = create(:submission, solution:)
        create(:iteration, idx: 1, solution:, submission:)

        use_capybara_host do
          visit track_exercise_solution_path(exercise.track, exercise, author.handle)
          click_on "Share"

          share_url = track_exercise_solution_url(exercise.track, exercise, author.handle)
          assert_link(
            "Twitter",
            href: uri_encode(
              "https://twitter.com/intent/tweet?url=#{share_url}&title=View this solution on Exercism"
            )
          )
          assert_button share_url
        end
      end
    end
  end
end
