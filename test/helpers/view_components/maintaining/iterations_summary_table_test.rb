require_relative "../view_component_test_case"

class MaintainingIterationsSummaryTableTest < ViewComponentTestCase
  test "maintaining iterations summary table rendered correctly" do
    user = create(:user)
    track = create(:track, slug: "ruby", title: "Ruby", repo_url: "https://github.com/exercism/v3")
    create(:user_track, user: user, track: track)
    concept_exercise = create(:concept_exercise, track: track, uuid: SecureRandom.uuid, slug: "numbers", prerequisites: [], title: "numbers")
    practice_exercise = create(:practice_exercise, track: track, uuid: SecureRandom.uuid, slug: "bob", prerequisites: [], title: "bob")
    concept_solution = create(:concept_solution, exercise: concept_exercise, user: user, uuid: SecureRandom.uuid)
    practice_solution = create(:practice_solution, exercise: practice_exercise, user: user, uuid: SecureRandom.uuid)

    iterations = [
      create(:iteration, solution: concept_solution, submitted_via: "cli", analysis_status: :inconclusive),
      create(:iteration, solution: concept_solution, submitted_via: "cli", tests_status: :passed),
      create(:iteration, solution: practice_solution, submitted_via: "script", representation_status: :disapproved)
    ]

    assert_component_equal ViewComponents::Maintaining::IterationsSummaryTable.new(iterations).to_s,
                           { id: "maintaining-iterations-summary-table", props: { iterations: [
                             { "id": 1, "track": "Ruby", "exercise": "numbers", "testsStatus": "pending", "representationStatus": "pending", "analysisStatus": "inconclusive" },
                             { "id": 2, "track": "Ruby", "exercise": "numbers", "testsStatus": "passed", "representationStatus": "pending", "analysisStatus": "pending" },
                             { "id": 3, "track": "Ruby", "exercise": "bob", "testsStatus": "pending", "representationStatus": "disapproved", "analysisStatus": "pending" }
                           ] } }
  end
end
