class NotificationsMailer < ApplicationMailer
  def mentor_started_discussion
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track

    subject = "#{@discussion.mentor.handle} has started mentoring you on #{@track.title}/#{@exercise.title}"
    mail_to_user(@user, subject)
  end

  def mentor_replied_to_discussion
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track

    subject = "#{@discussion.mentor.handle} has commented in your discussion on #{@track.title}/#{@exercise.title}"
    mail_to_user(@user, subject)
  end

  def student_replied_to_discussion
    notification = params[:notification]
    @user = notification.user
    @discussion = notification.discussion
    @exercise = @discussion.exercise
    @track = @exercise.track

    subject = "[Mentoring] #{@discussion.student.handle} has commented in your discussion on #{@track.title}/#{@exercise.title}" # rubocop:disable Layout/LineLength
    mail_to_user(@user, subject)
  end
end
