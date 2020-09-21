require "application_system_test_case"

module Example
  class IterationsSummaryTableTest < ApplicationSystemTestCase
    test "visiting the index" do
      solution = create :concept_solution
      iteration = create :iteration, solution: solution

      visit test_components_example_iterations_summary_table_url(solution.id)
      wait_for_websockets

      assert_text "#{iteration.id}: pending"

      iteration.tests_passed!
      iteration.broadcast!

      wait_for_websockets
      assert_text "#{iteration.id}: passed"
    end
  end
end
