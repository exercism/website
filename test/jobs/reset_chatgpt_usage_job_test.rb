require "test_helper"

class ResetChatGPTUsageJobTest < ActiveJob::TestCase
  test "reset chatgpt 3.5 usage to nil for premium users" do
    premium_user_1 = create :user, :premium
    premium_user_2 = create :user, :premium
    insider_user = create :user, :insider
    user = create :user

    User::IncrementUsage.(premium_user_1, :chatgpt, '3.5')
    User::IncrementUsage.(premium_user_1, :chatgpt, '3.5')
    User::IncrementUsage.(premium_user_1, :chatgpt, '4.0')
    User::IncrementUsage.(premium_user_2, :chatgpt, '3.5')
    User::IncrementUsage.(insider_user, :chatgpt, '3.5')
    User::IncrementUsage.(user, :chatgpt, '3.5')

    assert_equal 2, premium_user_1.usages['chatgpt']['3.5']
    assert_equal 1, premium_user_1.usages['chatgpt']['4.0']
    assert_equal 1, premium_user_2.usages['chatgpt']['3.5']
    assert_equal 1, insider_user.usages['chatgpt']['3.5']
    assert_equal 1, user.usages['chatgpt']['3.5']

    ResetChatGPTUsageJob.perform_now

    premium_user_1.reload
    assert_nil premium_user_1.usages['chatgpt']['3.5']
    assert_nil premium_user_1.usages['chatgpt']['4.0']

    premium_user_2.reload
    assert_nil premium_user_2.usages['chatgpt']['3.5']
    assert_nil premium_user_2.usages['chatgpt']['4.0']

    insider_user.reload
    assert_equal 1, insider_user.usages['chatgpt']['3.5']

    user.reload
    assert_equal 1, user.usages['chatgpt']['3.5']
  end
end
