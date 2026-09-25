# TODO: We should be able to use notification.email_key
# rather than setting unsubscribe keys manually
class NotificationsMailer < ApplicationMailer
  MENTORING_SUBJECT_PREFIX = "[Mentoring]".freeze

  def mentor_started_discussion
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track
    setup_advert!

    subject = t(".subject", mentor_handle: @discussion.mentor.handle, track_title: @track.title, exercise_title: @exercise.title)
    @unsubscribe_key = :email_on_mentor_started_discussion_notification
    @title = t(".title")
    transactional_mail(@user, subject)
  end

  def mentor_replied_to_discussion
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track
    setup_advert!

    subject = t(".subject", mentor_handle: @discussion.mentor.handle, track_title: @track.title, exercise_title: @exercise.title)
    @unsubscribe_key = :email_on_mentor_replied_to_discussion_notification
    @title = t(".title")
    transactional_mail(@user, subject)
  end

  def student_replied_to_discussion
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track
    setup_advert!

    subject = mentoring_subject(".subject", student_handle: @discussion.student.handle, track_title: @track.title,
      exercise_title: @exercise.title)
    @unsubscribe_key = :email_on_student_replied_to_discussion_notification
    @title = t(".title")
    transactional_mail(@user, subject)
  end

  def student_added_iteration
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @iteration = notification.iteration
    @exercise = @discussion.exercise
    @track = @exercise.track
    setup_advert!

    subject = mentoring_subject(".subject", student_handle: @discussion.student.handle, track_title: @track.title,
      exercise_title: @exercise.title)
    @unsubscribe_key = :email_on_student_added_iteration_notification
    @title = t(".title")
    transactional_mail(@user, subject)
  end

  def added_to_contributors_page
    notification = params[:notification]
    @user = notification.user

    subject = t(".subject")
    @unsubscribe_key = :email_on_general_update_notification
    @title = t(".title")
    transactional_mail(@user, subject)
  end

  def acquired_badge
    notification = params[:notification]
    @user = notification.user

    subject = t(".subject")
    @unsubscribe_key = :email_on_acquired_badge_notification
    @title = t(".title")
    transactional_mail(@user, subject)
  end

  def acquired_trophy
    notification = params[:notification]
    @user = notification.user
    @track = notification.track

    subject = t(".subject")
    @unsubscribe_key = :email_on_acquired_trophy_notification
    @title = t(".title")
    transactional_mail(@user, subject)
  end

  def joined_exercism
    notification = params[:notification]
    @user = notification.user

    @hide_header = true
    subject = t(".subject")
    transactional_mail(@user, subject)
  end

  def onboarding_product
    notification = params[:notification]
    @user = notification.user

    subject = t(".subject")
    transactional_mail(@user, subject)
  end

  def onboarding_community
    notification = params[:notification]
    @user = notification.user

    subject = t(".subject")
    transactional_mail(@user, subject)
  end

  def onboarding_insiders
    notification = params[:notification]
    @user = notification.user

    subject = t(".subject")
    transactional_mail(@user, subject)
  end

  def nudge_to_request_mentoring
    @notification = params[:notification]
    @user = @notification.user
    @unsubscribe_key = :email_on_nudge_notification

    subject = t(".subject")
    @title = t(".title")
    transactional_mail(@user, subject)
  end

  def student_finished_discussion
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track
    setup_advert!

    @unsubscribe_key = :email_on_student_finished_discussion_notification
    @title = t(".title")
    subject = mentoring_subject(".subject", student_handle: @discussion.student.handle, track_title: @track.title,
      exercise_title: @exercise.title)
    transactional_mail(@user, subject)
  end

  def mentor_finished_discussion
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track
    setup_advert!

    @unsubscribe_key = :email_on_mentor_finished_discussion_notification
    @title = t(".title")
    subject = mentoring_subject(".subject", mentor_handle: @discussion.mentor.handle, track_title: @track.title,
      exercise_title: @exercise.title)
    transactional_mail(@user, subject)
  end

  def automated_feedback_added
    notification = params[:notification]
    @user = notification.user
    @iteration = notification.iteration
    @exercise = @iteration.exercise
    @track = @iteration.track
    @emphasis = notification.emphasis
    setup_advert!

    @unsubscribe_key = :email_on_automated_feedback_added_notification
    @title = t(".title")
    subject = t(".subject", track_title: @track.title, exercise_title: @exercise.title)
    transactional_mail(@user, subject)
  end

  def eligible_for_insiders
    notification = params[:notification]
    @user = notification.user

    @hide_header = true
    subject = t(".subject")
    transactional_mail(@user, subject)
  end

  def eligible_for_lifetime_insiders
    notification = params[:notification]
    @user = notification.user

    @hide_header = true
    subject = t(".subject")
    transactional_mail(@user, subject)
  end

  def joined_insiders
    notification = params[:notification]
    @user = notification.user

    @hide_header = true
    subject = t(".subject")
    transactional_mail(@user, subject)
  end

  def joined_lifetime_insiders
    notification = params[:notification]
    @user = notification.user

    @hide_header = true
    subject = t(".subject")
    transactional_mail(@user, subject)
  end

  def upgraded_to_lifetime_insiders
    notification = params[:notification]
    @user = notification.user

    @hide_header = true
    subject = t(".subject")
    transactional_mail(@user, subject)
  end

  def expired_insiders
    notification = params[:notification]
    @user = notification.user

    @hide_header = true
    subject = t(".subject")
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

    @title = t(".title", num_days_waiting: @num_days_waiting)
    subject = t(".subject", num_days_waiting: @num_days_waiting)
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

    @title = t(".title", num_days_waiting: @num_days_waiting)
    subject = mentoring_subject(".subject", student_handle: @discussion.student.handle, num_days_waiting: @num_days_waiting)
    transactional_mail(@user, subject)
  end

  def mentor_timed_out_discussion_student
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track

    @unsubscribe_key = :email_on_mentor_timed_out_discussion_notification

    @title = t(".title")
    subject = t(".subject", track_title: @track.title, exercise_title: @exercise.title)
    transactional_mail(@user, subject)
  end

  def mentor_timed_out_discussion_mentor
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track

    @unsubscribe_key = :email_on_mentor_timed_out_discussion_notification

    @title = t(".title")
    subject = mentoring_subject(".subject")
    transactional_mail(@user, subject)
  end

  def student_timed_out_discussion_student
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track

    @unsubscribe_key = :email_on_student_timed_out_discussion_notification

    @title = t(".title")
    subject = t(".subject", track_title: @track.title, exercise_title: @exercise.title)
    transactional_mail(@user, subject)
  end

  def student_timed_out_discussion_mentor
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track

    @unsubscribe_key = :email_on_student_timed_out_discussion_notification

    @title = t(".title")
    subject = mentoring_subject(".subject")
    transactional_mail(@user, subject)
  end

  def setup_advert!
    @advert = Partner::Advert.for_track(@track)
  end

  def mentoring_subject(key, **) = "#{MENTORING_SUBJECT_PREFIX} #{t(key, **)}"
end
