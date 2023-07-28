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
    user = create :user
    reputation_token = create(:user_reputation_token, user:)
    assert_user_data_cache_reset(user, :has_unseen_reputation_tokens?, false) do
      User::ReputationToken::MarkAsSeen.(reputation_token)
    end
  end

  test "does not reset cache if token was already seen" do
    reputation_token = create :user_reputation_token, seen: true

    User::ResetCache.expects(:defer).never

    User::ReputationToken::MarkAsSeen.(reputation_token)
  end
end
