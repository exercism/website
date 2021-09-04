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

  def badge_acquired
    BadgesMailer.with(
      acquired_badge: User::AcquiredBadge.first
    ).awarded
  end
end
