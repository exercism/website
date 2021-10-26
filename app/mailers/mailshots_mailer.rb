class MailshotsMailer < ApplicationMailer
  layout false

  def v3_launch
    @user = params[:user]

    subject = "Explore a brand new Exercism"
    mail_to_user(@user, subject)
  end
end
