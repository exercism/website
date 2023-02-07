class MailshotsPreview < ActionMailer::Preview
  delegate :community_launch, to: :mailer
  delegate :company_support_donor, to: :mailer
  delegate :company_support_testimonial, to: :mailer
  delegate :challenge_12in23_launch, to: :mailer
  delegate :challenge_12in23_calendar, to: :mailer
  delegate :functional_february, to: :mailer
  delegate :upcoming_jose_valim, to: :mailer

  private
  def mailer
    MailshotsMailer.with(user: User.fourth, email_communication_preferences_key: :email_about_events)
  end
end
