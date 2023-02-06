class MailshotsPreview < ActionMailer::Preview
  def community_launch = MailshotsMailer.with(user: User.first).community_launch
  def company_support_donor = MailshotsMailer.with(user: User.first).company_support_donor
  def company_support_testimonial = MailshotsMailer.with(user: User.first).company_support_testimonial
  def challenge_12in23_launch = MailshotsMailer.with(user: User.first).challenge_12in23_launch
  def challenge_12in23_calendar = MailshotsMailer.with(user: User.fourth).challenge_12in23_calendar
  def functional_february = MailshotsMailer.with(user: User.fourth).functional_february
end
