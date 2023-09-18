require "test_helper"

class User::AcquiredBadge::SearchTest < ActiveSupport::TestCase
  test "no options returns everything" do
    user = create :user
    token = create(:user_acquired_badge, user:)

    # Someone else's token
    create :user_acquired_badge

    assert_equal [token], User::AcquiredBadge::Search.(user)
  end

  test "criteria" do
    user = create :user
    member_badge = create :user_acquired_badge, user:, badge: create(:member_badge)
    rookie_badge = create :user_acquired_badge, user:, badge: create(:rookie_badge)

    assert_equal [rookie_badge, member_badge], User::AcquiredBadge::Search.(user)
    assert_equal [rookie_badge, member_badge], User::AcquiredBadge::Search.(user, criteria: " ")
    assert_equal [member_badge], User::AcquiredBadge::Search.(user, criteria: "mem")
    assert_equal [rookie_badge], User::AcquiredBadge::Search.(user, criteria: "rook")
  end

  test "sort oldest first" do
    user = create :user
    token_1 = create(:user_acquired_badge, user:)
    token_2 = create :user_acquired_badge, user:, badge: create(:rookie_badge)

    assert_equal [token_1, token_2], User::AcquiredBadge::Search.(user, order: "oldest_first")
  end

  test "sort newest first by default" do
    user = create :user
    token_1 = create(:user_acquired_badge, user:)
    token_2 = create :user_acquired_badge, user:, badge: create(:rookie_badge)

    assert_equal [token_2, token_1], User::AcquiredBadge::Search.(user)
  end

  # TODO: Add third here and switch order of 1/2 when we have a third badge
  test "sort by unrevealed first" do
    user = create :user
    token_2 = create :user_acquired_badge, user:, revealed: false, badge: create(:rookie_badge)
    token_1 = create :user_acquired_badge, user:, revealed: true
    # token_3 = create :user_acquired_badge, user: user, revealed: true
    # assert_equal [token_2, token_3, token_1], User::AcquiredBadge::Search.(user, order: :unrevealed_first)
    assert_equal [token_2, token_1], User::AcquiredBadge::Search.(user, order: :unrevealed_first)
  end
end
