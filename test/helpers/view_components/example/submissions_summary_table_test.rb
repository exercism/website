require_relative "../view_component_test_case"

class ExampleSubmissionsSummaryTableTest < ViewComponentTestCase
  test "example submissions summary table rendered correctly" do
    user = create(:user)
    track = create(:track, slug: "ruby", title: "Ruby", repo_url: "https://github.com/exercism/v3")
    create(:user_track, user: user, track: track)
    exercise = create(:concept_exercise, track: track, uuid: SecureRandom.uuid, slug: "numbers", prerequisites: [], title: "numbers")
    solution = create(:concept_solution, exercise: exercise, user: user, uuid: SecureRandom.uuid)
    submission_1 = create(:submission, solution: solution, submitted_via: "cli", analysis_status: :inconclusive)
    submission_2 = create(:submission, solution: solution, submitted_via: "cli", tests_status: :passed)

    assert_component ViewComponents::Example::SubmissionsSummaryTable.new(solution).to_s,
      "example-submissions-summary-table",
      {
        solution_id: solution.id,
        submissions: [
          { "id": submission_1.id, "testsStatus": "pending" },
          { "id": submission_2.id, "testsStatus": "passed" }
        ]
      }
  end
end
