require_relative "../view_component_test_case"

class ExampleIterationsSummaryTableTest < ViewComponentTestCase
  test "example iterations summary table rendered correctly" do
    user = create(:user)
    track = create(:track, slug: "ruby", title: "Ruby", repo_url: "https://github.com/exercism/v3")
    create(:user_track, user: user, track: track)
    exercise = create(:concept_exercise, track: track, uuid: SecureRandom.uuid, slug: "numbers", prerequisites: [], title: "numbers")
    solution = create(:concept_solution, exercise: exercise, user: user, uuid: SecureRandom.uuid)
    create(:iteration, solution: solution, submitted_via: "cli", analysis_status: :inconclusive)
    create(:iteration, solution: solution, submitted_via: "cli", tests_status: :passed)

    assert_component_equal ViewComponents::Example::IterationsSummaryTable.new(solution).to_s,
                           { id: "maintaining-iterations-summary-table",
                             props: {
                               solution_id: 1,
                               iterations: [
                                 { "id": 1, "testsStatus": "pending" },
                                 { "id": 2, "testsStatus": "passed" }
                               ]
                             } }
  end
end
