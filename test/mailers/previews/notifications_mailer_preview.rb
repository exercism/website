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

  def student_replied_to_discussion
    NotificationsMailer.with(
      notification: User::Notifications::StudentRepliedToDiscussionNotification.first
    ).student_replied_to_discussion
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
end
