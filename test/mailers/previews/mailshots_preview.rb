class MailshotsPreview < ActionMailer::Preview
  def launch_trophies
    MailshotsMailer.with(
      user: User.first
    ).launch_trophies
  end

  def mailshot
    mailshot = Mailshot.find_by!(slug: params[:slug])
    MailshotsMailer.with(
      user: User.fourth,
      mailshot:
    ).mailshot
  end

  delegate :community_launch, to: :mailer
  delegate :company_support_donor, to: :mailer
  delegate :company_support_testimonial, to: :mailer
  delegate :mechanical_march, to: :mailer
  delegate :now_louis_pilfold, to: :mailer

  private
  def mailer
    MailshotsMailer.with(
      user: User.fourth,
      email_communication_preferences_key: :email_about_events
    )
  end
end
