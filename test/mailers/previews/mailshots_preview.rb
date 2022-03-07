class MailshotsPreview < ActionMailer::Preview
  def v3_launch
    MailshotsMailer.with(
      user: User.first
    ).v3_launch
  end

  def march_2022
    MailshotsMailer.with(
      user: User.first
    ).march_2022
  end
end
