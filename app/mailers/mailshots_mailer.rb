class MailshotsMailer < ApplicationMailer
  layout false

  def v3_launch
    @user = params[:user]

    subject = "We've launched Exercism v3, rebuilt from scratch 🎉"
    mail_to_user(@user, subject)
  end

  def march_2022
    @user = params[:user]

    subject = "[Exercism Newsletter] We're hiring!"
    mail_to_user(@user, subject)
  end
end
