require 'test_helper'

class Submission::LinkApproachTest < ActiveSupport::TestCase
  test "update approach" do
    approach = create :exercise_approach
    submission = create(:submission, approach: nil)

    Submission::LinkApproach.(submission, approach)

    assert_equal approach, submission.approach
  end

  test "update num submissions of old and new approach" do
    old_approach = create :exercise_approach
    new_approach = create :exercise_approach
    submission = create(:submission, approach: old_approach)
    create(:submission, approach: old_approach)
    create(:submission, approach: new_approach)

    Submission::LinkApproach.(submission, new_approach)

    assert_equal 1, old_approach.reload.num_submissions
    assert_equal 2, new_approach.reload.num_submissions
  end

  test "noop when approach is the same as current approach" do
    updated_at = Time.current - 3.days
    approach = create :exercise_approach
    submission = create(:submission, approach:, updated_at:)

    Submission::LinkApproach.(submission, approach)

    assert_equal updated_at, submission.updated_at

    submission.update_column(:approach_id, nil)
    Submission::LinkApproach.(submission, nil)

    assert_equal updated_at, submission.updated_at
  end
end
