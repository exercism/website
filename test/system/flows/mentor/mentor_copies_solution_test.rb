require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/clipboard_helpers"

module Flows
  module Mentor
    class MentorCopiesSolutionTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include ClipboardHelpers

      test "mentor copies solution to clipboard" do
        mentor = create :user
        solution = create :concept_solution
        submission = create(:submission, solution:)
        create :submission_file, submission:, filename: "file1.txt", content: "file 1"
        create :submission_file, submission:, filename: "file2.txt", content: "file 2"
        create(:iteration, solution:, submission:)
        discussion = create(:mentor_discussion, solution:, mentor:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          click_on "Copy solution"

          assert_text "Copied"
          expected = <<~TEXT.chomp
            file 1




            file 2
          TEXT
          assert_clipboard_text expected
        end
      end
    end
  end
end
