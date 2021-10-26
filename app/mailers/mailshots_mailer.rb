class MailshotsMailer < ApplicationMailer
  layout false

  def v3_launch
    @user = params[:user]

    subject = "Check out our brand new learning platform 🎉"
    mail_to_user(@user, subject)
  end
end
