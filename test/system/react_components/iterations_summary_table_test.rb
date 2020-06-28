require "application_system_test_case"

class IterationsSummaryTableTest < ApplicationSystemTestCase
  test "visiting the index" do
    solution = create :concept_solution
    iteration = create :iteration, solution: solution

    visit test_components_iterations_summary_table_url(solution.id)
    sleep(0.1) # Set the websocket connection

    assert_text "#{iteration.id}: pending"

    iteration.tests_passed!
    iteration.broadcast!

    sleep(0.1) # Wait for websocket to broadcast
    assert_text "#{iteration.id}: passed"
  end
end
