# The goal of this job is to re-sync sponsors to ensure
# that our payment and subscription data are correct
class FinishAbandonedMentorDiscussionsJob < ApplicationJob
  queue_as :dribble

  def perform = Mentor::Discussion::FinishAbandoned.()
end
