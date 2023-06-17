class MailshotsMailer < ApplicationMailer
  layout false

  default from: "Jeremy Walker <hello@mail.exercism.io>", reply_to: "jonathan@exercism.org"

  def mailshot
    @user = params[:user]
    @mailshot = params[:mailshot]

    bulk_mail(@user, @mailshot.subject)
  end
end
