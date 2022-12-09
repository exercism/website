class MailshotsMailer < ApplicationMailer
  layout false

  default from: "Jeremy Walker <hello@mail.exercism.io>", reply_to: "jonathan@exercism.org"

  def community_launch
    @user = params[:user]

    subject = "Forum, Swag, Automated Feedback, and a new Dig Deeper section"
    mail_to_user(@user, subject)
  end

  def company_support_donor
    @user = params[:user]

    subject = "Could your company support Exercism?"
    mail_to_user(@user, subject, reply_to: "loretta@exercism.org")
  end

  def company_support_testimonial
    @user = params[:user]

    subject = "Could your company support Exercism?"
    mail_to_user(@user, subject, reply_to: "loretta@exercism.org")
  end
end
