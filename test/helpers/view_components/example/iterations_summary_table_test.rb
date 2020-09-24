require_relative "../view_component_test_case"

class ExampleIterationsSummaryTableTest < ViewComponentTestCase
  test "example iterations summary table rendered correctly" do
    user = create(:user)
    track = create(:track, slug: "ruby", title: "Ruby", repo_url: "https://github.com/exercism/v3")
    create(:user_track, user: user, track: track)
    exercise = create(:concept_exercise, track: track, uuid: SecureRandom.uuid, slug: "numbers", prerequisites: [], title: "numbers")
    solution = create(:concept_solution, exercise: exercise, user: user, uuid: SecureRandom.uuid)
    iteration_1 = create(:iteration, solution: solution, submitted_via: "cli", analysis_status: :inconclusive)
    iteration_2 = create(:iteration, solution: solution, submitted_via: "cli", tests_status: :passed)

    assert_component_equal ViewComponents::Example::IterationsSummaryTable.new(solution).to_s,
                           { id: "example-iterations-summary-table",
                             props: {
                               solution_id: solution.id,
                               iterations: [
                                 { "id": iteration_1.id, "testsStatus": "pending" },
                                 { "id": iteration_2.id, "testsStatus": "passed" }
                               ]
                             } }
  end
end
