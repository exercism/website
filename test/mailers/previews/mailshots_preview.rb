class MailshotsPreview < ActionMailer::Preview
  def v3_launch
    MailshotsMailer.with(
      user: User.first
    ).v3_launch
  end
end
