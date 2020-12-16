require "application_system_test_case"

module Maintaining
  class SubmissionsSummaryTableTest < ApplicationSystemTestCase
    test "visiting the index" do
      sign_in!

      visit test_components_maintaining_submissions_summary_table_url
      wait_for_websockets

      solution = create :concept_solution
      submission = create :submission, solution: solution

      submission.tests_passed!
      submission.broadcast!

      wait_for_websockets
      assert_text submission.id.to_s
    end
  end
end
