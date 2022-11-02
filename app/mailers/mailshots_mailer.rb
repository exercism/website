class MailshotsMailer < ApplicationMailer
  layout false

  def community_launch
    @user = params[:user]

    subject = "We've launched Exercism v3, rebuilt from scratch 🎉"
    mail_to_user(@user, subject)
  end
end
