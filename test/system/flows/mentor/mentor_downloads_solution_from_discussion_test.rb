require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/clipboard_helpers"

module Flows
  module Mentor
    class MentorDownloadsSolutionFromDiscussionTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include ClipboardHelpers

      test "mentor copies download command to clipboard" do
        mentor = create :user
        solution = create :concept_solution
        submission = create :submission, solution: solution
        create :iteration, solution: solution, submission: submission
        discussion = create :mentor_discussion, solution: solution, mentor: mentor

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          click_on "Download solution"
          click_on "exercism download"

          assert_clipboard_text "exercism download --uuid=#{solution.uuid}"
        end
      end
    end
  end
end
