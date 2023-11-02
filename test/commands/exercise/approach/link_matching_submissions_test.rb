require "test_helper"

class Exercise::Approach::LinkMatchingSubmissionsTest < ActiveSupport::TestCase
  test "link to submissions matching the conditions that are not yet linked to any approach" do
    tag = "paradigm:imperative"
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:)
    other_approach = create(:exercise_approach, exercise:)
    create(:exercise_approach_tag, approach:, tag:, condition_type: :any)
    create(:exercise_approach_tag, approach: other_approach, tag:, condition_type: :all)
    submission_1 = create(:submission, exercise:, approach: nil, analysis_status: :completed)
    create(:submission_analysis, submission: submission_1, tags_data: { tags: [tag] })
    submission_2 = create(:submission, exercise:, approach: nil, analysis_status: :completed)
    create(:submission_analysis, submission: submission_2, tags_data: { tags: [tag] })

    # Sanity check
    assert_nil submission_1.approach
    assert_nil submission_2.approach

    Exercise::Approach::LinkMatchingSubmissions.(approach)

    assert_equal approach, submission_1.reload.approach
    assert_equal approach, submission_2.reload.approach
  end

  test "don't change submissions matching the conditions that are already linked to approach" do
    tag = "paradigm:imperative"
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:)
    create(:exercise_approach_tag, approach:, tag:, condition_type: :any)
    submission_1 = create(:submission, exercise:, approach:, analysis_status: :completed)
    create(:submission_analysis, submission: submission_1, tags_data: { tags: [tag] })
    submission_2 = create(:submission, exercise:, approach:, analysis_status: :completed)
    create(:submission_analysis, submission: submission_2, tags_data: { tags: [tag] })

    Exercise::Approach::LinkMatchingSubmissions.(approach)

    assert_equal approach, submission_1.reload.approach
    assert_equal approach, submission_2.reload.approach
  end

  test "don't link to submissions already linked to other approach" do
    tag = "paradigm:imperative"
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:)
    other_approach = create(:exercise_approach, exercise:)
    create(:exercise_approach_tag, approach:, tag:, condition_type: :any)
    create(:exercise_approach_tag, approach: other_approach, tag:, condition_type: :all)
    submission_1 = create(:submission, exercise:, approach: other_approach, analysis_status: :completed)
    create(:submission_analysis, submission: submission_1, tags_data: { tags: [tag] })
    submission_2 = create(:submission, exercise:, approach: other_approach, analysis_status: :completed)
    create(:submission_analysis, submission: submission_2, tags_data: { tags: [tag] })

    Exercise::Approach::LinkMatchingSubmissions.(approach)

    assert_equal other_approach, submission_1.reload.approach
    assert_equal other_approach, submission_2.reload.approach
  end

  test "re-link approaches already linked to approach when approach no longer has tags" do
    tag = "paradigm:imperative"
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:)
    other_approach = create(:exercise_approach, exercise:)
    create(:exercise_approach_tag, approach: other_approach, tag:, condition_type: :any)
    submission_1 = create(:submission, exercise:, approach:, analysis_status: :completed)
    create(:submission_analysis, submission: submission_1, tags_data: { tags: [tag] })
    submission_2 = create(:submission, exercise:, approach:, analysis_status: :completed)
    create(:submission_analysis, submission: submission_2, tags_data: { tags: [tag] })

    perform_enqueued_jobs do
      Exercise::Approach::LinkMatchingSubmissions.(approach)
    end

    assert_equal other_approach, submission_1.reload.approach
    assert_equal other_approach, submission_2.reload.approach
  end
end
