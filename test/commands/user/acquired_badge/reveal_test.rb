require "test_helper"

class User::AcquiredBadge::RevealTest < ActiveSupport::TestCase
  test "reveals testominal" do
    user = create :user
    badge = create :contributor_badge
    acquired_badge = create(:user_acquired_badge, user:, badge:)

    # Sanity check
    refute acquired_badge.revealed?

    User::AcquiredBadge::Reveal.(acquired_badge)

    assert acquired_badge.revealed?
  end

  test "resets user cache" do
    user = create :user
    badge = create :contributor_badge
    acquired_badge = create(:user_acquired_badge, user:, badge:)

    # Sanity check
    refute acquired_badge.revealed?

    User::ResetCache.expects(:defer).with(user)

    User::AcquiredBadge::Reveal.(acquired_badge)
  end

  test "does not reset user cache if already revealed" do
    user = create :user
    badge = create :contributor_badge
    acquired_badge = create(:user_acquired_badge, revealed: true, user:, badge:)

    User::ResetCache.expects(:defer).never

    User::AcquiredBadge::Reveal.(acquired_badge)
  end
end
