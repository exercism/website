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
    transactional_mail(@user, subject)
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
    transactional_mail(@user, subject)
  end

  def student_replied_to_discussion
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track

    subject = "[Mentoring] #{@discussion.student.handle} has commented in your discussion on #{@track.title}/#{@exercise.title}"
    @unsubscribe_key = :email_on_student_replied_to_discussion_notification
    @title = "Your student has replied"
    transactional_mail(@user, subject)
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
    transactional_mail(@user, subject)
  end

  def added_to_contributors_page
    notification = params[:notification]
    @user = notification.user

    subject = "You have been added to Exercism's contributors page"
    @unsubscribe_key = :email_on_general_update_notification
    @title = "You're officially an Exercism contributor!"
    transactional_mail(@user, subject)
  end

  def acquired_badge
    notification = params[:notification]
    @user = notification.user

    subject = "You've unlocked a new badge"
    @unsubscribe_key = :email_on_acquired_badge_notification
    @title = "There's a new badge waiting for you to reveal!"
    transactional_mail(@user, subject)
  end

  def acquired_trophy
    notification = params[:notification]
    @user = notification.user
    @track = notification.track

    subject = "You've unlocked a new trophy"
    @unsubscribe_key = :email_on_acquired_trophy_notification
    @title = "There's a new trophy waiting for you to reveal!"
    transactional_mail(@user, subject)
  end

  def joined_exercism
    notification = params[:notification]
    @user = notification.user

    @hide_header = true
    subject = "Welcome to Exercism"
    transactional_mail(@user, subject)
  end

  def onboarding_product
    notification = params[:notification]
    @user = notification.user

    subject = "How are you getting on with Exercism?"
    transactional_mail(@user, subject)
  end

  def onboarding_community
    notification = params[:notification]
    @user = notification.user

    subject = "Have you said hello on Discord or our forum yet?"
    transactional_mail(@user, subject)
  end

  def onboarding_insiders
    notification = params[:notification]
    @user = notification.user

    subject = "Did you know we're a not-for-profit?"
    transactional_mail(@user, subject)
  end

  def nudge_to_request_mentoring
    @notification = params[:notification]
    @user = @notification.user
    @unsubscribe_key = :email_on_nudge_notification

    subject = "Level up with feedback from our mentors"
    @title = "Level up with feedback from our mentors!"
    transactional_mail(@user, subject)
  end

  def student_finished_discussion
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track

    @unsubscribe_key = :email_on_student_finished_discussion_notification
    @title = "Your student has finished the discussion"
    subject = "[Mentoring] #{@discussion.student.handle} has ended your discussion on #{@track.title}/#{@exercise.title}"
    transactional_mail(@user, subject)
  end

  def mentor_finished_discussion
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track

    @unsubscribe_key = :email_on_mentor_finished_discussion_notification
    @title = "Your mentor has finished the discussion"
    subject = "[Mentoring] #{@discussion.mentor.handle} has ended your discussion on #{@track.title}/#{@exercise.title}"
    transactional_mail(@user, subject)
  end

  def automated_feedback_added
    notification = params[:notification]
    @user = notification.user
    @iteration = notification.iteration
    @exercise = @iteration.exercise
    @track = @iteration.track
    @emphasis = notification.emphasis

    @unsubscribe_key = :email_on_automated_feedback_added_notification
    @title = "New automated feedback is available"
    subject = "There's new feedback on your solution to #{@track.title}/#{@exercise.title}"
    transactional_mail(@user, subject)
  end

  def eligible_for_insiders
    notification = params[:notification]
    @user = notification.user

    @hide_header = true
    subject = "You're eligible for Exercism Insiders"
    transactional_mail(@user, subject)
  end

  def eligible_for_lifetime_insiders
    notification = params[:notification]
    @user = notification.user

    @hide_header = true
    subject = "You're eligible for Exercism Insiders"
    transactional_mail(@user, subject)
  end

  def joined_insiders
    notification = params[:notification]
    @user = notification.user

    @hide_header = true
    subject = "Welcome to Exercism Insiders"
    transactional_mail(@user, subject)
  end

  def joined_lifetime_insiders
    notification = params[:notification]
    @user = notification.user

    @hide_header = true
    subject = "Welcome to Exercism Lifetime Insiders"
    transactional_mail(@user, subject)
  end

  def upgraded_to_lifetime_insiders
    notification = params[:notification]
    @user = notification.user

    @hide_header = true
    subject = "You've been upgraded to Exercism Lifetime Insiders"
    transactional_mail(@user, subject)
  end

  def expired_insiders
    notification = params[:notification]
    @user = notification.user

    @hide_header = true
    subject = "Exercism Insiders membership expired"
    transactional_mail(@user, subject)
  end

  def nudge_student_to_reply_in_discussion
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track
    @num_days_waiting = notification.num_days_waiting
    @num_days_to_time_out = notification.num_days_to_time_out

    @unsubscribe_key = :email_on_nudge_student_to_reply_in_discussion_notification

    @title = "Your mentor has been waiting #{@num_days_waiting} days for your reply"
    subject = "Your mentor has been waiting #{@num_days_waiting} days for your reply."
    transactional_mail(@user, subject)
  end

  def nudge_mentor_to_reply_in_discussion
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track
    @num_days_waiting = notification.num_days_waiting
    @num_days_to_time_out = notification.num_days_to_time_out

    @unsubscribe_key = :email_on_nudge_mentor_to_reply_in_discussion_notification

    @title = "Your student has been waiting #{@num_days_waiting} days for your reply"
    subject = "[Mentoring] #{@discussion.student.handle} is waiting for you to reply (#{@num_days_waiting} day nudge)"
    transactional_mail(@user, subject)
  end

  def mentor_timed_out_discussion_student
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track

    @unsubscribe_key = :email_on_mentor_timed_out_discussion_notification

    @title = "Your discussion has timed out"
    subject = "The discussion on your solution to #{@track.title}/#{@exercise.title} has timed out"
    transactional_mail(@user, subject)
  end

  def mentor_timed_out_discussion_mentor
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track

    @unsubscribe_key = :email_on_mentor_timed_out_discussion_notification

    @title = "Your mentoring session has timed out"
    subject = "[Mentoring] Your mentoring session has timed out due to lack of response by you."
    transactional_mail(@user, subject)
  end

  def student_timed_out_discussion_student
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track

    @unsubscribe_key = :email_on_student_timed_out_discussion_notification

    @title = "Your discussion has timed out"
    subject = "Your mentoring discussion on #{@track.title}/#{@exercise.title} has timed out"
    transactional_mail(@user, subject)
  end

  def student_timed_out_discussion_mentor
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track

    @unsubscribe_key = :email_on_student_timed_out_discussion_notification

    @title = "Your student's discussion has timed-out"
    subject = "[Mentoring] Your mentoring session has timed out due to lack of student response."
    transactional_mail(@user, subject)
  end
end
