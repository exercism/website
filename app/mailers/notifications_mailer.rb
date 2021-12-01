# TODO: We should be able to use notification.email_key
# rather than setting unsubscribe keys manually
class NotificationsMailer < ApplicationMailer
  def mentor_started_discussion
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track

    subject = "#{@discussion.mentor.handle} has started mentoring you on #{@track.title}/#{@exercise.title}"
    @unsubscribe_key = :email_on_mentor_started_discussion_notification
    @title = "Your solution is being mentored"
    mail_to_user(@user, subject)
  end

  def mentor_replied_to_discussion
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track

    subject = "#{@discussion.mentor.handle} has commented in your discussion on #{@track.title}/#{@exercise.title}"
    @unsubscribe_key = :email_on_mentor_replied_to_discussion_notification
    @title = "Your mentor has replied"
    mail_to_user(@user, subject)
  end

  def student_replied_to_discussion
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track

    subject = "[Mentoring] #{@discussion.student.handle} has commented in your discussion on #{@track.title}/#{@exercise.title}" # rubocop:disable Layout/LineLength
    @unsubscribe_key = :email_on_student_replied_to_discussion_notification
    @title = "Your student has replied"
    mail_to_user(@user, subject)
  end

  def student_added_iteration
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @iteration = notification.iteration
    @exercise = @discussion.exercise
    @track = @exercise.track

    subject = "[Mentoring] #{@discussion.student.handle} has submitted a new iteration on the solution you are mentoring for #{@track.title}/#{@exercise.title}" # rubocop:disable Layout/LineLength
    @unsubscribe_key = :email_on_student_added_iteration_notification
    @title = "Your student has submitted a new iteration"
    mail_to_user(@user, subject)
  end

  def added_to_contributors_page
    notification = params[:notification]
    @user = notification.user

    subject = "You have been added to Exercism's contributors page"
    @unsubscribe_key = :email_on_general_update_notification
    @title = "You're officially an Exercism contributor!"
    mail_to_user(@user, subject)
  end

  def acquired_badge
    notification = params[:notification]
    @user = notification.user

    subject = "You've unlocked a new badge"
    @unsubscribe_key = :email_on_acquired_badge_notification
    @title = "There's a new badge waiting for you to reveal!"
    mail_to_user(@user, subject)
  end

  def joined_exercism
    notification = params[:notification]
    @user = notification.user

    subject = "Welcome to Exercism"
    @title = "Welcome to Exercism!"
    mail_to_user(@user, subject)
  end

  def nudge_to_request_mentoring
    @notification = params[:notification]
    @user = @notification.user
    @unsubscribe_key = :email_on_nudge_notification

    subject = "Level up with feedback from our mentors"
    @title = "Level up with feedback from our mentors!"
    mail_to_user(@user, subject)
  end
end
