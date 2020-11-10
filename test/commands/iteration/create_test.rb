require 'test_helper'

class Iteration::CreateTest < ActiveSupport::TestCase
  test "increments iteration" do
    solution = create :concept_solution

    it_1 = Iteration::Create.(solution, create(:submission, solution: solution))
    assert_equal 1, it_1.idx

    it_2 = Iteration::Create.(solution, create(:submission, solution: solution))
    assert_equal 2, it_2.idx

    it_3 = Iteration::Create.(solution, create(:submission, solution: solution))
    assert_equal 3, it_3.idx

    # Check different count for different solution
    other_solution = create :concept_solution
    it_4 = Iteration::Create.(other_solution, create(:submission, solution: other_solution))
    assert_equal 1, it_4.idx
  end

  test "returns existing in case of duplicate" do
    solution = create :concept_solution
    submission = create :submission, solution: solution

    first = Iteration::Create.(solution, submission)
    second = Iteration::Create.(solution, submission)
    assert_equal first, second
  end

  test "creates activity" do
    user = create :user
    exercise = create :concept_exercise
    solution = create :concept_solution, exercise: exercise, user: user
    submission = create :submission, solution: solution

    iteration = Iteration::Create.(solution, submission)

    activity = User::Activities::SubmittedIterationActivity.last
    assert_equal user, activity.user
    assert_equal exercise.track, activity.track
    assert_equal exercise, activity.exercise
    assert_equal iteration, activity.iteration
  end
end
