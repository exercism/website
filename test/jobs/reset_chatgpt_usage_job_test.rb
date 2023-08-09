require "test_helper"

class ResetChatGPTUsageJobTest < ActiveJob::TestCase
  test "reset chatgpt 3.5 usage to nil for insiders" do
    insider_user = create :user, :insider
    user = create :user

    User::IncrementUsage.(insider_user, :chatgpt, '3.5')
    User::IncrementUsage.(insider_user, :chatgpt, '3.5')
    User::IncrementUsage.(insider_user, :chatgpt, '4.0')
    User::IncrementUsage.(user, :chatgpt, '3.5')

    assert_equal 2, insider_user.usages['chatgpt']['3.5']
    assert_equal 1, insider_user.usages['chatgpt']['4.0']
    assert_equal 1, user.usages['chatgpt']['3.5']

    ResetChatGPTUsageJob.perform_now

    insider_user.reload
    assert_nil insider_user.usages['chatgpt']['3.5']
    assert_nil insider_user.usages['chatgpt']['4.0']

    user.reload
    assert_equal 1, user.usages['chatgpt']['3.5']
  end
end
