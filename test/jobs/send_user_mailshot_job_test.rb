require "test_helper"

class SendUserMailshotJobTest < ActiveJob::TestCase
  test "sends email" do
    user = create :user
    mailshot = create :mailshot

    User::Mailshot::Send.expects(:call).with(user, mailshot)

    SendUserMailshotJob.perform_now(user, mailshot)
  end

  test "sends email to correct queue" do
    user = create :user
    mailshot = create :mailshot

    job = MailshotsMailer.with(user:, mailshot:).send(:mailshot).deliver_later

    assert_equal 'mailers', job.queue_name
  end
end
