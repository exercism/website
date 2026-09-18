class ApplicationMailer < ActionMailer::Base
  prepend_view_path "app/views/mailers"
  default reply_to: "jeremy@exercism.org"

  layout "mailer"
  helper :email

  rescue_from(Mail::Field::IncompleteParseError) {}
  rescue_from(Net::SMTPSyntaxError) {}
  rescue_from(Net::SMTPFatalError) {}

  def process(action, *args)
    I18n.with_locale(recipient_locale(args)) { super }
  end

  def user_email_with_name(user)
    name = user.name.presence || user.handle
    email_address_with_name(user.email, name)
  end

  def transactional_mail(*args, **kwargs)
    delivery_method_options = {
      user_name: Exercism.secrets.transactional_smtp_username,
      password: Exercism.secrets.transactional_smtp_password,
      address: Exercism.secrets.transactional_smtp_address,
      port: Exercism.secrets.transactional_smtp_port,
      authentication: Exercism.secrets.transactional_smtp_authentication,
      enable_starttls_auto: true
    }
    mail_to_user(
      *args,
      from: "Exercism <hello@#{Exercism.secrets.transactional_smtp_sending_domain}>",
      delivery_method_options:,
      **kwargs
    )
  end

  def bulk_mail(*args, **kwargs)
    delivery_method_options = {
      user_name: Exercism.secrets.transactional_smtp_username,
      password: Exercism.secrets.transactional_smtp_password,
      address: Exercism.secrets.transactional_smtp_address,
      port: Exercism.secrets.transactional_smtp_port,
      authentication: Exercism.secrets.transactional_smtp_authentication,
      enable_starttls_auto: true
    }
    mail_to_user(
      *args,
      from: "Jeremy from Exercism <hello@#{Exercism.secrets.transactional_smtp_sending_domain}>",
      delivery_method_options:,
      **kwargs
    )
  end

  def mail_to_email(email, subject)
    delivery_method_options = {
      user_name: Exercism.secrets.transactional_smtp_username,
      password: Exercism.secrets.transactional_smtp_password,
      address: Exercism.secrets.transactional_smtp_address,
      port: Exercism.secrets.transactional_smtp_port,
      authentication: Exercism.secrets.transactional_smtp_authentication,
      enable_starttls_auto: true
    }
    mail(
      to: email,
      from: "Jeremy from Exercism <hello@#{Exercism.secrets.transactional_smtp_sending_domain}>",
      subject:,
      delivery_method_options:
    )
  end

  private
  # TODO(iHiD): OPEN. What "the user's locale" is.
  def recipient_locale(args) = Locale::Normalize.(recipient(args)&.locale) || I18n.default_locale

  def recipient(args)
    return args.first if args.first.is_a?(User) # Devise passes the user positionally

    candidates = params.to_h.values_at(:user, :notification, :payment)
    candidates.compact.filter_map { |c| c.is_a?(User) ? c : c.try(:user) }.first
  end

  def mail_to_user(user, subject, from:, delivery_method_options:, **options)
    return unless user.may_receive_emails?

    begin
      @preview_text = render_to_string(template: "#{mailer_name}/#{action_name}", formats: [:text]). # rubocop:disable Style/StringConcatenation
        tr("\n", " ").squeeze(" ")[0, 150] + "..."
    rescue StandardError => e
      # We're fine with @preview_text being nil if it has to be
      # but we should never get here.
      Sentry.capture_exception(e)
    end

    mail(
      to: user_email_with_name(user),
      subject:,
      from:,
      delivery_method_options:,
      **options
    )
  end
end
