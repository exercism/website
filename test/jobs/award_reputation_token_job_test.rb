require "test_helper"

class AwardReputationTokenJobTest < ActiveJob::TestCase
  test "create command is called" do
    user = mock
    type = mock
    params = mock

    User::ReputationToken::Create.expects(:call).with(user, type, params)
    AwardReputationTokenJob.perform_now(user, type, params)
  end
end
