class SendMentorDiscussionNudgesJob < ApplicationJob
  queue_as :dribble

  def perform = Mentor::Discussion::SendNudges.()
end
