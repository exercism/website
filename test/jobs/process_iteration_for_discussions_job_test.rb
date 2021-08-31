require "test_helper"

class ProcessIterationForDiscussionsJobTest < ActiveJob::TestCase
  test "does not send notifications to finished discussions" do
    solution = create :concept_solution
    create :mentor_discussion, solution: solution, status: :finished
    submission = create :submission, solution: solution
    iteration = create :iteration, solution: solution, submission: submission

    ProcessIterationForDiscussionsJob.perform_now(iteration)

    assert_equal 0, User::Notification.count
  end
end
