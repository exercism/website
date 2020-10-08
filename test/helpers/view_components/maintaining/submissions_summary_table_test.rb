require_relative "../view_component_test_case"

class MaintainingSubmissionsSummaryTableTest < ViewComponentTestCase
  test "maintaining submissions summary table rendered correctly" do
    user = create(:user)
    track = create(:track, slug: "ruby", title: "Ruby", repo_url: "https://github.com/exercism/v3")
    create(:user_track, user: user, track: track)
    concept_exercise = create(:concept_exercise, track: track, uuid: SecureRandom.uuid, slug: "numbers", prerequisites: [], title: "numbers")
    practice_exercise = create(:practice_exercise, track: track, uuid: SecureRandom.uuid, slug: "bob", prerequisites: [], title: "bob")
    concept_solution = create(:concept_solution, exercise: concept_exercise, user: user, uuid: SecureRandom.uuid)
    practice_solution = create(:practice_solution, exercise: practice_exercise, user: user, uuid: SecureRandom.uuid)
    submission_1 = create(:submission, solution: concept_solution, submitted_via: "cli", analysis_status: :inconclusive)
    submission_2 = create(:submission, solution: concept_solution, submitted_via: "cli", tests_status: :passed)
    submission_3 = create(:submission, solution: practice_solution, submitted_via: "script", representation_status: :disapproved)
    submissions = [submission_1, submission_2, submission_3]

    assert_component ViewComponents::Maintaining::SubmissionsSummaryTable.new(submissions).to_s,
      "maintaining-submissions-summary-table",
      {
        submissions: [
          { "id": submission_1.id, "track": "Ruby", "exercise": "numbers", "testsStatus": "pending", "representationStatus": "pending", "analysisStatus": "inconclusive" },
          { "id": submission_2.id, "track": "Ruby", "exercise": "numbers", "testsStatus": "passed", "representationStatus": "pending", "analysisStatus": "pending" },
          { "id": submission_3.id, "track": "Ruby", "exercise": "bob", "testsStatus": "pending", "representationStatus": "disapproved", "analysisStatus": "pending" }
        ]
      }
  end
end
