class ResetChatGPTUsageJob < ApplicationJob
  queue_as :cron

  def perform
    User.with_data.insiders.find_each do |user|
      User::ResetUsage.(user, :chatgpt, '3.5')
      User::ResetUsage.(user, :chatgpt, '4.0')
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end
end
