require_relative "../react_component_test_case"

class ReactComponents::Maintaining::SubmissionsSummaryTableTest < ReactComponentTestCase
  test "maintaining submissions summary table rendered correctly" do
    user = create(:user)
    track = create(:track)
    create(:user_track, user:, track:)
    concept_exercise = create(:concept_exercise, track:, uuid: SecureRandom.uuid, slug: "numbers", prerequisites: [], title: "numbers")
    practice_exercise = create(:practice_exercise, track:, uuid: SecureRandom.uuid, slug: "bob", prerequisites: [], title: "bob")
    concept_solution = create(:concept_solution, exercise: concept_exercise, user:, uuid: SecureRandom.uuid)
    practice_solution = create(:practice_solution, exercise: practice_exercise, user:, uuid: SecureRandom.uuid)
    submission_1 = create(:submission, solution: concept_solution, submitted_via: "cli", analysis_status: :completed)
    submission_2 = create(:submission, solution: concept_solution, submitted_via: "cli", tests_status: :passed)
    submission_3 = create(:submission, solution: practice_solution, submitted_via: "script", representation_status: :generated)

    serializer = ReactComponents::Maintaining::SubmissionsSummaryTable::SerializeSubmissionForTable
    assert_component ReactComponents::Maintaining::SubmissionsSummaryTable.new(Submission.limit(10)),
      "maintaining-submissions-summary-table",
      {
        submissions: [
          serializer.(submission_1),
          serializer.(submission_2),
          serializer.(submission_3)
        ]
      }
  end

  test "gracefully handle missing tooling job data" do
    user = create(:user)
    track = create(:track)
    create(:user_track, user:, track:)
    concept_exercise = create(:concept_exercise, track:, uuid: SecureRandom.uuid, slug: "numbers", prerequisites: [], title: "numbers")
    practice_exercise = create(:practice_exercise, track:, uuid: SecureRandom.uuid, slug: "bob", prerequisites: [], title: "bob")
    concept_solution = create(:concept_solution, exercise: concept_exercise, user:, uuid: SecureRandom.uuid)
    practice_solution = create(:practice_solution, exercise: practice_exercise, user:, uuid: SecureRandom.uuid)
    submission_1 = create(:submission, solution: concept_solution, submitted_via: "cli", analysis_status: :completed)
    submission_2 = create(:submission, solution: practice_solution, submitted_via: "script", representation_status: :generated)

    # Setting tests_status to :errored causes fetching the tooling job to raise an exception
    submission_3 = create(:submission, solution: concept_solution, submitted_via: "cli", tests_status: :errored)

    serializer = ReactComponents::Maintaining::SubmissionsSummaryTable::SerializeSubmissionForTable
    assert_component ReactComponents::Maintaining::SubmissionsSummaryTable.new(Submission.limit(10)),
      "maintaining-submissions-summary-table",
      {
        submissions: [
          serializer.(submission_1),
          serializer.(submission_2),
          serializer.(submission_3)
        ]
      }
  end
end
