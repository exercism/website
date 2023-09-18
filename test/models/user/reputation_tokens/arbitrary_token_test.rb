require "test_helper"

class User::ReputationTokens::ArbitraryTokenTest < ActiveSupport::TestCase
  test "creates arbitrary reputation token" do
    freeze_time do
      user = create :user, handle: "User22", github_username: "user22"

      User::ReputationToken::Create.(
        user,
        :arbitrary,
        arbitrary_value: 23,
        arbitrary_reason: 'For helping troubleshoot'
      )

      assert_equal 1, user.reputation_tokens.size
      rt = user.reputation_tokens.first

      assert_instance_of User::ReputationTokens::ArbitraryToken, rt
      assert_equal 'For helping troubleshoot', rt.text
      assert_equal :'For helping troubleshoot', rt.reason
      assert_equal :misc, rt.category
      assert_equal 23, rt.value
      assert_equal Time.current.to_date, rt.earned_on
      assert_nil rt.track
    end
  end

  test "creates arbitrary reputation token linked to track" do
    freeze_time do
      user = create :user, handle: "User33", github_username: "user33"
      track = create :track

      User::ReputationToken::Create.(
        user,
        :arbitrary,
        arbitrary_value: 500,
        arbitrary_reason: 'For building the test runner',
        track:
      )

      assert_equal 1, user.reputation_tokens.size
      rt = user.reputation_tokens.first

      assert_instance_of User::ReputationTokens::ArbitraryToken, rt
      assert_equal 'For building the test runner', rt.text
      assert_equal :'For building the test runner', rt.reason
      assert_equal :misc, rt.category
      assert_equal 500, rt.value
      assert_equal Time.current.to_date, rt.earned_on
      assert_equal track, rt.track
    end
  end

  test "each arbitrary reputation token is unique" do
    user = create :user, handle: "User22", github_username: "user22"

    User::ReputationToken::Create.(
      user,
      :arbitrary,
      arbitrary_value: 23,
      arbitrary_reason: 'For helping troubleshoot'
    )

    User::ReputationToken::Create.(
      user,
      :arbitrary,
      arbitrary_value: 23,
      arbitrary_reason: 'For helping troubleshoot'
    )

    assert_equal 2, user.reputation_tokens.size
    rt_1 = user.reputation_tokens.first
    rt_2 = user.reputation_tokens.second

    refute_equal rt_1.uniqueness_key, rt_2.uniqueness_key
  end
end
