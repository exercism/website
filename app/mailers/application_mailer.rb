class ApplicationMailer < ActionMailer::Base
  prepend_view_path "app/views/mailers"
  default reply_to: "jeremy@exercism.org"

  layout "mailer"
  helper :email

  rescue_from(Mail::Field::IncompleteParseError) {}
  rescue_from(Net::SMTPSyntaxError) {}
  rescue_from(Net::SMTPFatalError) {}

  # TODO(iHiD): OPEN. Whether emails are localised from launch. Flip this to
  # turn it on. Until then every email is in English, links included.
  LOCALISE_EMAILS = false

  # The whole action runs in the recipient's locale: the subject and title
  # are built in the action, the templates are rendered by mail(), and the
  # links in them follow I18n.locale. This happens in Sidekiq, where there
  # is no request to have set a locale.
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
  # TODO(iHiD): OPEN. What "the user's locale" is. Today it is the single
  # user_data.locale column. See LocaleRouting#user_locale.
  def recipient_locale(args)
    return I18n.default_locale unless LOCALISE_EMAILS

    user = recipient(args)
    locale = Locale::Normalize.(user&.locale)
    locale && Locale::MayView.(locale, user) ? locale : I18n.default_locale
  end

  # Known before the action runs, so that all of it is in one locale.
  def recipient(args)
    return args.first if args.first.is_a?(User) # Devise

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
