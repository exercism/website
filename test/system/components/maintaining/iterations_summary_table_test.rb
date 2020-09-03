require "application_system_test_case"

module Maintaining
  class IterationsSummaryTableTest < ApplicationSystemTestCase
    test "visiting the index" do
      visit test_components_maintaining_iterations_summary_table_url
      wait_for_websockets

      solution = create :concept_solution
      iteration = create :iteration, solution: solution

      iteration.tests_passed!
      iteration.broadcast!

      wait_for_websockets
      assert_text iteration.id.to_s
    end
  end
end
