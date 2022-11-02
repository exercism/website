class MailshotsPreview < ActionMailer::Preview
  def community_launch
    MailshotsMailer.with(
      user: User.first
    ).community_launch
  end
end
