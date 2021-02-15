class SerializeUserNotifications
  include Mandate

  initialize_with :notifications

  def call
    notifications.
      map { |r| serialize_notification(r) }
  end

  private
  def serialize_notification(notification)
    notification.rendering_data
  end
end
