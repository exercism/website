module Emailable
  extend ActiveSupport::Concern

  included do
    enum email_status: { pending: 0, skipped: 1, sent: 2, failed: 3 }, _prefix: :email
  end

  def email_communication_preferences_key = raise "email_communication_preferences_key must be implemented by a child class"

  # This is a hook that children can use to
  # add custom logic for whether an email should
  # be sent (see User::Notification for example)
  def email_should_send? = true
end
