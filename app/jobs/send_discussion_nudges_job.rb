class SendDiscussionNudgesJob < ApplicationJob
  queue_as :dribble

  def perform = Mentor::Discussion::SendNudges.()
end
