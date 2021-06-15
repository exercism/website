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
end
