require 'test_helper'

class Submission::LinkApproachTest < ActiveSupport::TestCase
  test "update approach" do
    approach = create :exercise_approach
    submission = create(:submission, approach: nil)

    Submission::LinkApproach.(submission, approach)

    assert_equal approach, submission.approach
  end

  test "update num solutions of old and new approach" do
    old_approach = create :exercise_approach
    new_approach = create :exercise_approach
    solution = create :practice_solution
    other_solution = create :practice_solution
    submission = create(:submission, approach: old_approach, solution:)
    create(:submission, approach: old_approach, solution:)
    create(:submission, approach: new_approach, solution: other_solution)

    Submission::LinkApproach.(submission, new_approach)

    assert_equal 1, old_approach.reload.num_solutions
    assert_equal 2, new_approach.reload.num_solutions
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

  test "does not change the updated_at date for the approach" do
    updated_at = Time.current - 3.days
    approach = create(:exercise_approach, updated_at:)
    submission = create(:submission, approach: nil)

    Submission::LinkApproach.(submission, approach)

    assert_equal updated_at, approach.updated_at
  end
end
