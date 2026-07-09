class MailshotsMailer < ApplicationMailer
  layout false

  # Slugs whose Mailshot maps to a bespoke action on this mailer (with its own
  # template), rather than the generic, DB-content-driven :mailshot action.
  # A Mailshot with one of these slugs is sent via
  # User::Mailshot::SendWithCustomMailer instead of User::Mailshot::Send.
  CUSTOM_MAILER_SLUGS = %w[jiki_launch].freeze

  def mailshot
    @user = params[:user]
    @mailshot = params[:mailshot]

    bulk_mail(@user, @mailshot.subject)
  end

  def jiki_launch
    @user = params[:user]
    @translator = @user.translator_locales.present?

    subject = "Learn to Build in the LLM Era. Meet Jiki."
    @email_communication_preferences_key = :receive_product_updates
    bulk_mail(@user, subject)
  end
end
