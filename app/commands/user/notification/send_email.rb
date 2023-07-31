class User::Notification::SendEmail
  include Mandate

  initialize_with :notification

  def call
    User::SendEmail.(notification) do
      NotificationsMailer.with(notification:).
        send(notification.email_type).deliver_later
    end
  end
end
