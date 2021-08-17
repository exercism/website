require 'test_helper'

class User::ReputationTokens::MarkAllAsSeenTest < ActiveSupport::TestCase
  test "clears all user_reputation_tokens for user" do
    user = create :user
    user_reputation_token = create :user_reputation_token, user: user
    other_user_reputation_token = create :user_reputation_token

    User::ReputationToken::MarkAllAsSeen.(user)

    assert user_reputation_token.reload.seen?
    refute other_user_reputation_token.reload.seen?
  end

  test "broadcasts message" do
    user = create :user
    create :user_reputation_token, user: user
    ReputationChannel.expects(:broadcast_changed!).with(user)

    User::ReputationToken::MarkAllAsSeen.(user)
  end

  test "does not broadcast if none were changed" do
    user = create :user
    create :user_reputation_token, user: user, seen: true
    ReputationChannel.expects(:broadcast_changed!).never

    User::ReputationToken::MarkAllAsSeen.(user)
  end
end
