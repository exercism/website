require "application_system_test_case"

module Maintaining
  class SubmissionsSummaryTableTest < ApplicationSystemTestCase
    test "visiting the index" do
      sign_in!

      use_capybara_host do
        visit test_components_maintaining_submissions_summary_table_url
        wait_for_websockets

        solution = create :concept_solution
        submission = create(:submission, solution:)

        submission.tests_passed!
        submission.broadcast!

        wait_for_websockets
        assert_text submission.uuid
      end
    end
  end
end
