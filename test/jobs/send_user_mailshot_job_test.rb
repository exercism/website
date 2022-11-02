require "test_helper"

class SendUserMailshotJobTest < ActiveJob::TestCase
  test "sends email" do
    user = create :user
    mailshot_id = :community_launch

    User::Mailshot::Send.expects(:call).with(user, mailshot_id)

    SendUserMailshotJob.perform_now(user, mailshot_id)
  end
end
