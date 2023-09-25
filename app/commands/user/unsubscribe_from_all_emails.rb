class User::UnsubscribeFromAllEmails
  include Mandate

  initialize_with :user

  def call
    user.communication_preferences.update!(
      email_on_mentor_started_discussion_notification: false,
      email_on_mentor_replied_to_discussion_notification: false,
      email_on_student_replied_to_discussion_notification: false,
      email_on_student_added_iteration_notification: false,
      email_on_new_solution_comment_for_solution_user_notification: false,
      email_on_new_solution_comment_for_other_commenter_notification: false,
      receive_product_updates: false,
      email_on_remind_mentor: false,
      email_on_mentor_heartbeat: false,
      email_on_general_update_notification: false,
      email_on_acquired_badge_notification: false,
      email_on_acquired_trophy_notification: false,
      email_on_nudge_notification: false,
      email_on_student_finished_discussion_notification: false,
      email_on_mentor_finished_discussion_notification: false,
      email_on_automated_feedback_added_notification: false,
      email_about_fundraising_campaigns: false,
      email_on_nudge_student_to_reply_in_discussion_notification: false,
      email_on_nudge_mentor_to_reply_in_discussion_notification: false,
      email_on_mentor_timed_out_discussion_notification: false,
      email_on_student_timed_out_discussion_notification: false,
      email_about_events: false,
      receive_onboarding_emails: false,
      email_about_insiders: false
    )
  end
end
