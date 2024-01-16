class ProcessTimedOutMentorDiscussionsJob < ApplicationJob
  queue_as :dribble

  def perform
    Mentor::Discussion::UpdateTimedOut.()
    Mentor::Discussion::FinishAbandoned.()
  end
end
