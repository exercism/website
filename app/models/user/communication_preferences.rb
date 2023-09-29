class User::CommunicationPreferences < ApplicationRecord
  belongs_to :user

  def self.keys = self.mentoring_keys + self.product_keys

  def self.mentoring_keys
    %i[
      email_on_mentor_started_discussion_notification
      email_on_mentor_replied_to_discussion_notification
      email_on_mentor_finished_discussion_notification
      email_on_student_replied_to_discussion_notification
      email_on_student_finished_discussion_notification
      email_on_student_added_iteration_notification
      email_on_automated_feedback_added_notification
      email_on_nudge_student_to_reply_in_discussion_notification
      email_on_nudge_mentor_to_reply_in_discussion_notification
      email_on_student_timed_out_discussion_notification
      email_on_mentor_timed_out_discussion_notification
    ]
  end

  def self.product_keys
    %i[
      email_on_acquired_badge_notification
      email_on_acquired_trophy_notification
      email_on_general_update_notification
      email_on_nudge_notification
      email_about_fundraising_campaigns
      email_about_events
      receive_onboarding_emails
      receive_product_updates
    ]
  end

  before_create do
    self.token = SecureRandom.compact_uuid
  end
end
