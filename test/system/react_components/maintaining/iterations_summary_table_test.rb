require "application_system_test_case"

module Maintaining
  class IterationsSummaryTableTest < ApplicationSystemTestCase
    test "visiting the index" do
      visit test_components_maintaining_iterations_summary_table_url
      sleep(0.1) # Set the websocket connection

      solution = create :concept_solution
      iteration = create :iteration, solution: solution

      iteration.tests_passed!
      iteration.broadcast!

      sleep(0.1) # Wait for websocket to broadcast
      assert_text iteration.id.to_s
    end
  end
end
