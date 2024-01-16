require "test_helper"

class Solution::UpdatePublishedExerciseRepresentationTest < ActiveSupport::TestCase
  test "updates old and new representation" do
    exercise = create(:concept_exercise)
    old_representation = create(:exercise_representation, exercise:)
    new_representation = create(:exercise_representation, exercise:)
    solution = create(:concept_solution, :published, published_exercise_representation: old_representation, exercise:)
    submission = create(:submission, solution:)
    iteration = create(:iteration, submission:)
    create :submission_representation, submission: iteration.submission, ast: new_representation.ast

    Exercise::Representation::Recache.expects(:defer).with(old_representation, wait: 30.seconds)
    Exercise::Representation::Recache.expects(:defer).with(new_representation, wait: 30.seconds)

    solution.update!(published_iteration: iteration)
    Solution::UpdatePublishedExerciseRepresentation.(solution)

    assert_equal new_representation, solution.published_exercise_representation
  end

  test "copes without old representation" do
    exercise = create(:concept_exercise)
    new_representation = create(:exercise_representation, exercise:)
    solution = create(:concept_solution, :published, exercise:)
    submission = create(:submission, solution:)
    iteration = create(:iteration, submission:)
    create :submission_representation, submission: iteration.submission, ast: new_representation.ast

    Exercise::Representation::Recache.expects(:defer).with(new_representation, wait: 30.seconds)

    solution.update!(published_iteration: iteration)
    Solution::UpdatePublishedExerciseRepresentation.(solution)

    assert_equal new_representation, solution.published_exercise_representation
  end

  test "copes without new representation" do
    exercise = create(:concept_exercise)
    old_representation = create(:exercise_representation, exercise:)
    solution = create(:concept_solution, :published, published_exercise_representation: old_representation, exercise:)
    submission = create(:submission, solution:)
    iteration = create(:iteration, submission:)

    Exercise::Representation::Recache.expects(:defer).with(old_representation, wait: 30.seconds)

    solution.update!(published_iteration: iteration)
    Solution::UpdatePublishedExerciseRepresentation.(solution)

    assert_nil solution.published_exercise_representation
  end

  test "copes if not published" do
    exercise = create(:concept_exercise)
    old_representation = create(:exercise_representation, exercise:)
    solution = create(:concept_solution, published_exercise_representation: old_representation, exercise:)

    Exercise::Representation::Recache.expects(:defer).with(old_representation, wait: 30.seconds)

    Solution::UpdatePublishedExerciseRepresentation.(solution)

    assert_nil solution.published_exercise_representation
  end

  test "copes if not published and no old representation" do
    solution = create(:concept_solution)

    Exercise::Representation::Recache.expects(:defer).never

    Solution::UpdatePublishedExerciseRepresentation.(solution)

    assert_nil solution.published_exercise_representation
  end

  test "noop if they're the same" do
    exercise = create(:concept_exercise)
    representation = create(:exercise_representation, exercise:)
    solution = create(:concept_solution, :published, published_exercise_representation: representation, exercise:)
    submission = create(:submission, solution:)
    iteration = create(:iteration, submission:)
    create :submission_representation, submission: iteration.submission, ast: representation.ast

    Exercise::Representation::Recache.expects(:defer).never

    solution.update!(published_iteration: iteration)
    Solution::UpdatePublishedExerciseRepresentation.(solution)

    assert_equal representation, solution.published_exercise_representation
  end
end
