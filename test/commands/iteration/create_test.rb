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
    assert_equal solution, activity.solution
    assert_equal iteration, activity.iteration
  end

  test "starts analysis and representation" do
    filename_1 = "subdir/foobar.rb"
    content_1 = "'I think' = 'I am'"

    filename_2 = "barfood.rb"
    content_2 = "something = :else"

    solution = create :concept_solution
    submission = create :submission, solution: solution
    create :submission_file, submission: submission, filename: filename_1, content: content_1
    create :submission_file, submission: submission, filename: filename_2, content: content_2

    job_id = SecureRandom.uuid
    SecureRandom.stubs(uuid: job_id)

    Submission::Representation::Init.expects(:call).with(submission)

    # TODO: Readd this when analyses are reenabled
    # Submission::Analysis::Init.expects(:call).with(submission)

    Iteration::Create.(solution, submission)

    submission.reload
    assert :queued, submission.representation_status
    assert :queued, submission.analysis_status
  end
end
