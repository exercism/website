class ApplicationMailer < ActionMailer::Base
  prepend_view_path "app/views/mailers"
  default from: "The Exercism Team <hello@mail.exercism.io>", reply_to: "hello@exercism.io"

  layout "mailer"
  helper :email

  def user_email_with_name(user)
    name = user.name.presence || user.handle
    email_address_with_name(user.email, name)
  end

  def mail_to_user(user, subject)
    mail(to: user_email_with_name(user), subject: subject)
  end
end
