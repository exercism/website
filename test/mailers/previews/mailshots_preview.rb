class MailshotsPreview < ActionMailer::Preview
  def community_launch = MailshotsMailer.with(user: User.first).community_launch
  def company_support_donor = MailshotsMailer.with(user: User.first).company_support_donor
  def company_support_testimonial = MailshotsMailer.with(user: User.first).company_support_testimonial
end
