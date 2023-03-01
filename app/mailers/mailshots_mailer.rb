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

  def mechanical_march
    @user = params[:user]
    @email_communication_preferences_key = params[:email_communication_preferences_key]

    subject = "It's Functional February!"
    mail_to_user(@user, subject)
  end

  def upcoming_jose_valim
    @user = params[:user]
    @email_communication_preferences_key = params[:email_communication_preferences_key]

    subject = "This Thursday: Live interview with José Valim, creator of Elixir"
    mail_to_user(@user, subject)
  end

  def now_louis_pilfold
    @user = params[:user]
    @email_communication_preferences_key = params[:email_communication_preferences_key]

    subject = "Watch back our interview with Louis Pilfold, creator of Gleam"
    mail_to_user(@user, subject)
  end
end
