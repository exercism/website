class SerializeCommunicationPreferences
  include Mandate

  initialize_with :preferences

  def call
    {
      email_on_mentor_started_discussion_notification: preferences.email_on_mentor_started_discussion_notification
    }
  end
end
