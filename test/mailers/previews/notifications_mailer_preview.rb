class NotificationsMailerPreview < ActionMailer::Preview
  def mentor_started_discussion
    NotificationsMailer.with(
      notification: User::Notifications::MentorStartedDiscussionNotification.first
    ).mentor_started_discussion
  end

  def mentor_replied_to_discussion
    NotificationsMailer.with(
      notification: User::Notifications::MentorRepliedToDiscussionNotification.first
    ).mentor_replied_to_discussion
  end

  def mentor_finished_discussion
    NotificationsMailer.with(
      notification: User::Notifications::MentorFinishedDiscussionNotification.first
    ).mentor_finished_discussion
  end

  def student_replied_to_discussion
    NotificationsMailer.with(
      notification: User::Notifications::StudentRepliedToDiscussionNotification.first
    ).student_replied_to_discussion
  end

  def student_added_iteration
    NotificationsMailer.with(
    notification: User::Notifications::StudentAddedIterationNotification.first
  ).student_added_iteration
  end

  def student_finished_discussion
    NotificationsMailer.with(
      notification: User::Notifications::StudentFinishedDiscussionNotification.first
    ).student_finished_discussion
  end

  def added_to_contributors_page
    NotificationsMailer.with(
      notification: User::Notifications::AddedToContributorsPageNotification.first
    ).added_to_contributors_page
  end

  def acquired_badge
    NotificationsMailer.with(
      notification: User::Notifications::AcquiredBadgeNotification.first
    ).acquired_badge
  end

  def joined_exercism
    NotificationsMailer.with(
      notification: User::Notifications::JoinedExercismNotification.first
    ).joined_exercism
  end

  def nudge_to_request_mentoring
    NotificationsMailer.with(
      notification: User::Notifications::NudgeToRequestMentoringNotification.first
    ).nudge_to_request_mentoring
  end
end
