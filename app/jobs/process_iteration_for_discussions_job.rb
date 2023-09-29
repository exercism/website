class ProcessIterationForDiscussionsJob < ApplicationJob
  queue_as :default

  def perform(iteration)
    iteration.solution.mentor_discussions.awaiting_student.each do |discussion|
      Mentor::Discussion::AwaitingMentor.(discussion)

      User::Notification::Create.(
        discussion.mentor,
        :student_added_iteration,
        discussion:,
        iteration:
      )
    end
  end
end
