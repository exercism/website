class SerializeCommunicationPreferences
  include Mandate

  initialize_with :preferences

  def call
    {
      email_on_mentor_started_discussion_notification: preferences.email_on_mentor_started_discussion_notification,
      email_on_mentor_replied_to_discussion_notification: preferences.email_on_mentor_replied_to_discussion_notification,
      email_on_student_replied_to_discussion_notification: preferences.email_on_student_replied_to_discussion_notification,
      email_on_student_added_iteration_notification: preferences.email_on_student_added_iteration_notification,
      email_on_acquired_badge_notification: preferences.email_on_acquired_badge_notification,
      email_on_general_update_notification: preferences.email_on_general_update_notification,
      receive_product_updates: preferences.receive_product_updates

    }
  end
end
