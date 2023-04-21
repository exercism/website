require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Admin
    class AdminViewsMentorDiscussionTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "admin views mentor discussion but is not student nor mentor" do
        admin = create :user, :admin
        mentor = create :user, handle: "author"
        student = create :user, handle: "student-123"
        exercise = create :concept_exercise, slug: "lasagna"
        solution = create :concept_solution, exercise:, user: student
        submission = create(:submission, solution:)
        create :submission_file, submission:, filename: 'lasagna.rb', content: "def expected_time"
        discussion = create(:mentor_discussion, solution:, mentor:)
        create(:iteration, submission:, solution:)

        use_capybara_host do
          sign_in!(admin)
          visit mentoring_discussion_path(discussion)

          # Verify that the submitted file is shown
          assert_text "lasagna.rb"
          assert_text "def expected_time"

          # Verify that the discussion posts are shown
          assert_text "I could do with some help here"
        end
      end
    end
  end
end
