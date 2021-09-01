require "test_helper"

class ProcessIterationForDiscussionsJobTest < ActiveJob::TestCase
  test "sends notifications" do
    solution = create :concept_solution
    discussion = create :mentor_discussion, solution: solution, status: :finished
    submission = create :submission, solution: solution
    iteration = create :iteration, solution: solution, submission: submission

    User::Notification::Create.expects(:call).with(
      discussion.mentor,
      :student_added_iteration,
      { discussion: discussion, iteration: iteration }
    )

    ProcessIterationForDiscussionsJob.perform_now(iteration)
  end

  test "does not send notifications to finished discussions" do
    solution = create :concept_solution
    create :mentor_discussion, solution: solution, status: :finished
    submission = create :submission, solution: solution
    iteration = create :iteration, solution: solution, submission: submission

    ProcessIterationForDiscussionsJob.perform_now(iteration)

    assert_equal 0, User::Notification.count
  end
end
