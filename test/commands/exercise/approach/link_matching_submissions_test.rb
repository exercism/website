require "test_helper"

class Exercise::Approach::LinkMatchingSubmissionsTest < ActiveSupport::TestCase
  test "link approach to submissions with matching tags that are not yet linked to an approach" do
    tag = "paradigm:imperative"
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:, tags: { "any" => [tag] })
    create(:exercise_approach, exercise:, tags: { "all" => [tag] })
    submission_1 = create(:submission, exercise:, approach: nil, tags: [tag])
    create(:iteration, submission: submission_1)
    submission_2 = create(:submission, exercise:, approach: nil, tags: [tag])
    create(:iteration, submission: submission_2)

    # Sanity check: don't link to a submission with non-matching tags
    submission_3 = create(:submission, exercise:, approach: nil, tags: ["construct:if"])
    create(:iteration, submission: submission_3)

    # Sanity check: don't link to a submission without an iteration
    submission_4 = create(:submission, exercise:, approach: nil, tags: [tag])

    # Sanity check: don't link to a submission with empty tags
    submission_5 = create(:submission, exercise:, approach: nil, tags: [])
    create(:iteration, submission: submission_5)

    # Sanity check: don't link to a submission with no tags
    submission_6 = create(:submission, exercise:, approach: nil, tags: nil)
    create(:iteration, submission: submission_6)

    # Sanity check
    assert_nil submission_1.approach
    assert_nil submission_2.approach
    assert_nil submission_3.approach
    assert_nil submission_4.approach
    assert_nil submission_5.approach
    assert_nil submission_6.approach

    Exercise::Approach::LinkMatchingSubmissions.(approach)

    assert_equal approach, submission_1.reload.approach
    assert_equal approach, submission_2.reload.approach
    assert_nil submission_3.reload.approach
    assert_nil submission_4.reload.approach
    assert_nil submission_5.reload.approach
    assert_nil submission_6.reload.approach
  end

  test "keep link for submissions with matching tags that are already linked to the approach" do
    tag = "paradigm:imperative"
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:, tags: { "any" => [tag] })
    create(:exercise_approach, exercise:, tags: { "all" => [tag] })
    submission_1 = create(:submission, exercise:, approach:, tags: [tag])
    create(:iteration, submission: submission_1)
    submission_2 = create(:submission, exercise:, approach:, tags: [tag])
    create(:iteration, submission: submission_2)

    # Sanity check: don't link to a submission with non-matching tags
    submission_3 = create(:submission, exercise:, approach: nil, tags: ["construct:if"])
    create(:iteration, submission: submission_3)

    # Sanity check: don't link to a submission without an iteration
    submission_4 = create(:submission, exercise:, approach: nil, tags: [tag])

    # Sanity check: don't link to a submission with empty tags
    submission_5 = create(:submission, exercise:, approach: nil, tags: [])
    create(:iteration, submission: submission_5)

    # Sanity check: don't link to a submission with no tags
    submission_6 = create(:submission, exercise:, approach: nil, tags: nil)
    create(:iteration, submission: submission_6)

    # Sanity check
    assert_equal approach, submission_1.approach
    assert_equal approach, submission_2.approach
    assert_nil submission_3.approach
    assert_nil submission_4.approach
    assert_nil submission_5.approach
    assert_nil submission_6.approach

    Exercise::Approach::LinkMatchingSubmissions.(approach)

    assert_equal approach, submission_1.reload.approach
    assert_equal approach, submission_2.reload.approach
    assert_nil submission_3.reload.approach
    assert_nil submission_4.reload.approach
    assert_nil submission_5.reload.approach
    assert_nil submission_6.reload.approach
  end

  test "try link to other approach for submissions link to approach but which tags no longer match" do
    tag = "paradigm:imperative"
    exercise = create :practice_exercise
    approach = create(:exercise_approach, exercise:, tags: { "any" => [tag] })
    other_approach = create(:exercise_approach, exercise:, tags: { "all" => ["construct:while"] })
    create(:exercise_approach, exercise:, tags: { "all" => [tag] })

    submission_1 = create(:submission, exercise:, approach:, tags: ["construct:if"])
    create(:iteration, submission: submission_1)

    submission_2 = create(:submission, exercise:, approach:, tags: ["construct:while"])
    create(:iteration, submission: submission_2)

    # Sanity check
    assert_equal approach, submission_1.approach
    assert_equal approach, submission_2.approach

    perform_enqueued_jobs do
      Exercise::Approach::LinkMatchingSubmissions.(approach)
    end

    assert_nil submission_1.reload.approach
    assert_equal other_approach, submission_2.reload.approach
  end
end
