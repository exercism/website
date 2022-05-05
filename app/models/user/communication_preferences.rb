class User::CommunicationPreferences < ApplicationRecord
  belongs_to :user

  def self.keys
    mentoring_keys + solution_keys + general_keys
  end

  def self.mentoring_keys
    %i[
      email_on_mentor_started_discussion_notification
      email_on_mentor_replied_to_discussion_notification
      email_on_mentor_finished_discussion_notification
      email_on_student_replied_to_discussion_notification
      email_on_student_added_iteration_notification
      email_on_student_finished_discussion_notification
      email_on_remind_mentor
      email_on_mentor_heartbeat
    ]
  end

  def self.solution_keys
    %i[
      email_on_new_solution_comment_for_solution_user_notification
      email_on_new_solution_comment_for_other_commenter_notification
    ]
  end

  def self.general_keys
    %i[
      email_on_general_update_notification
      email_on_acquired_badge_notification
      email_on_nudge_notification
      receive_product_updates
    ]
  end

  before_create do
    self.token = SecureRandom.compact_uuid
  end
end
