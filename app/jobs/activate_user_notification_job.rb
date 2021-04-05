class ActivateUserNotificationJob < ApplicationJob
  queue_as :notifications

  def perform(notification)
    User::Notification::Activate.(notification)
  end
end
