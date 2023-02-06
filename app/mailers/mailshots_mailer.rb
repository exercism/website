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

  def challenge_12in23_launch
    @user = params[:user]

    subject = "Take the #12in23 Challenge"
    mail_to_user(@user, subject)
  end

  def challenge_12in23_calendar
    @user = params[:user]
    @signed_up = @user.challenges.where(challenge_id: "12in23").exists?

    subject = "Meet the #12in23 Calendar"
    mail_to_user(@user, subject)
  end

  def functional_february
    @user = params[:user]

    subject = "It's Functional February!"
    mail_to_user(@user, subject)
  end
end
