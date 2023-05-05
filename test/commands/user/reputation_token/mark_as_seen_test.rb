require 'test_helper'

class User::ReputationTokens::MarkAsSeenTest < ActiveSupport::TestCase
  test "marks reputation token as seen" do
    reputation_token = create :user_reputation_token

    # Sanity check
    refute reputation_token.seen?

    User::ReputationToken::MarkAsSeen.(reputation_token)

    assert reputation_token.reload.seen?
  end

  test "reset cache" do
    reputation_token = create :user_reputation_token

    User::ResetCache.expects(:defer).with(reputation_token.user)

    User::ReputationToken::MarkAsSeen.(reputation_token)
  end

  test "does not reset cache if token was already seen" do
    reputation_token = create :user_reputation_token, seen: true

    User::ResetCache.expects(:defer).never

    User::ReputationToken::MarkAsSeen.(reputation_token)
  end
end
