class SerializeNotifications
  include Mandate

  initialize_with :notifications

  def call
    notifications.
      map { |r| serialize_notification(r) }
  end

  private
  def serialize_notification(notification)
    {
      # TODO: Maybe expose a UUID instead?
      id: notification.id,
      text: notification.text,
      read: notification.read?,
      url: notification.url
    }
  end
end
