class UpdateMedianWaitTimesJob < ApplicationJob
  queue_as :default

  def perform
    Track::UpdateMedianWaitTimes.()
    Exercise::UpdateMedianWaitTimes.()
  end
end
