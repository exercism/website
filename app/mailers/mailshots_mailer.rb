class MailshotsMailer < ApplicationMailer
  layout false

  def mailshot
    @user = params[:user]
    @mailshot = params[:mailshot]

    bulk_mail(@user, @mailshot.subject)
  end
end
