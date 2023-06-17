class ApplicationMailer < ActionMailer::Base
  prepend_view_path "app/views/mailers"
  # TODO: Change to exercism.org when moving to AWS SES
  default from: "The Exercism Team <hello@mail.exercism.io>", reply_to: "hello@exercism.io"

  layout "mailer"
  helper :email

  rescue_from(Mail::Field::IncompleteParseError) {}
  rescue_from("Net::SMTPSyntaxError: 501 5.5.2 RCPT TO syntax error") {}

  def user_email_with_name(user)
    name = user.name.presence || user.handle
    email_address_with_name(user.email, name)
  end

  def transactional_mail(*args, **kwargs)
    delivery_options = {
      user_name: Exercism.secrets.transactional_smtp_username,
      password: Exercism.secrets.transactional_smtp_password,
      address: Exercism.secrets.transactional_smtp_address,
      domain: Exercism.secrets.transactional_smtp_address,
      port: Exercism.secrets.transactional_smtp_port,
      authentication: Exercism.secrets.transactional_smtp_authentication,
      enable_starttls_auto: true
    }
    mail_to_user(*args, **kwargs.merge(delivery_options:))
  end

  def bulk_mail(*args, **kwargs)
    delivery_options = {
      user_name: Exercism.secrets.bulk_smtp_username,
      password: Exercism.secrets.bulk_smtp_password,
      address: Exercism.secrets.bulk_smtp_address,
      domain: Exercism.secrets.bulk_smtp_address,
      port: Exercism.secrets.bulk_smtp_port,
      authentication: Exercism.secrets.bulk_smtp_authentication
    }
    mail_to_user(*args, **kwargs.merge(delivery_options:))
  end

  private
  def mail_to_user(user, subject, **options)
    return unless user.may_receive_emails?

    mail(to: user_email_with_name(user), subject:, **options)
  end
end
