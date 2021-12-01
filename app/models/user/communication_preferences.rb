class User::CommunicationPreferences < ApplicationRecord
  belongs_to :user

  def self.keys
    %i[
      email_on_mentor_started_discussion_notification
      email_on_mentor_replied_to_discussion_notification
      email_on_student_replied_to_discussion_notification
      email_on_student_added_iteration_notification
      email_on_acquired_badge_notification
      email_on_general_update_notification
      email_on_nudge_notification
      receive_product_updates
    ]
  end

  before_create do
    self.token = SecureRandom.compact_uuid
  end
end
