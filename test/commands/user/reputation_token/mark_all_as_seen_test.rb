require 'test_helper'

class User::ReputationTokens::MarkAllAsSeenTest < ActiveSupport::TestCase
  test "clears all user_reputation_tokens for user" do
    user = create :user
    user_reputation_token = create(:user_reputation_token, user:)
    other_user_reputation_token = create :user_reputation_token

    User::ReputationToken::MarkAllAsSeen.(user)

    assert user_reputation_token.reload.seen?
    refute other_user_reputation_token.reload.seen?
  end

  test "broadcasts message" do
    user = create :user
    create(:user_reputation_token, user:)
    ReputationChannel.expects(:broadcast_changed!).with(user)

    User::ReputationToken::MarkAllAsSeen.(user)
  end

  test "does not broadcast if none were changed" do
    user = create :user
    create :user_reputation_token, user:, seen: true
    ReputationChannel.expects(:broadcast_changed!).never

    User::ReputationToken::MarkAllAsSeen.(user)
  end

  test "reset cache" do
    user = create :user
    create(:user_reputation_token, user:)

    assert_user_data_cache_reset(user, :has_unseen_reputation_tokens?, false) do
      User::ReputationToken::MarkAllAsSeen.(user)
    end
  end

  test "does not reset cache if none were changed" do
    user = create :user
    create :user_reputation_token, user:, seen: true

    User::ResetCache.expects(:defer).never

    User::ReputationToken::MarkAllAsSeen.(user)
  end
end
