require "application_system_test_case"

module Example
  class SubmissionsSummaryTableTest < ApplicationSystemTestCase
    test "visiting the index" do
      solution = create :concept_solution
      submission = create :submission, solution: solution

      visit test_components_example_submissions_summary_table_url(solution.id)
      wait_for_websockets

      assert_text "#{submission.id}: pending"

      submission.tests_passed!
      submission.broadcast!

      wait_for_websockets
      assert_text "#{submission.id}: passed"
    end
  end
end
