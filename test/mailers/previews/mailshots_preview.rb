class MailshotsPreview < ActionMailer::Preview
  def community_launch = MailshotsMailer.with(user: User.first).community_launch
  def donor_company_support = MailshotsMailer.with(user: User.first).donor_company_support
end
