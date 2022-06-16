require "test_helper"

class ProcessIterationForDiscussionsJobTest < ActiveJob::TestCase
  test "sends notifications" do
    solution = create :concept_solution
    discussion = create :mentor_discussion, :awaiting_student, solution: solution
    submission = create :submission, solution: solution
    iteration = create :iteration, solution: solution, submission: submission

    User::Notification::Create.expects(:call).with(
      discussion.mentor,
      :student_added_iteration,
      { discussion:, iteration: }
    )

    ProcessIterationForDiscussionsJob.perform_now(iteration)
  end

  test "does not send notifications when action is already awaiting mentor" do
    solution = create :concept_solution
    create :mentor_discussion, :awaiting_mentor, solution: solution
    submission = create :submission, solution: solution
    iteration = create :iteration, solution: solution, submission: submission

    ProcessIterationForDiscussionsJob.perform_now(iteration)

    refute User::Notification.exists?
  end
end
