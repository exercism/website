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
      url: notification.url,
      text: notification.text,
      read: notification.read?,
      created_at: notification.created_at.iso8601,
      image_type: notification.image_type,
      image_url: notification.image_url
    }
  end
end
