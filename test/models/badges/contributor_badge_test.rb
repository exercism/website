require "test_helper"

class Badge::AnybodyThereBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :contributor_badge
    assert_equal "Contributor", badge.name
    assert_equal :legendary, badge.rarity
    assert_equal :contributors, badge.icon
    assert_equal 'Awarded for contributing to Exercism', badge.description
  end

  test "award_to for publishing doesn't count" do
    user = create :user
    create :user_published_solution_reputation_token, user: user
    badge = create :contributor_badge

    refute badge.award_to?(user)
  end

  test "award_to for building" do
    user = create :user
    create :user_code_contribution_reputation_token, user: user
    badge = create :contributor_badge

    assert badge.award_to?(user)
  end

  test "award_to for maintaining" do
    user = create :user
    create :user_code_merge_reputation_token, user: user
    badge = create :contributor_badge

    assert badge.award_to?(user)
  end

  test "award_to for authoring" do
    user = create :user
    create :user_exercise_author_reputation_token, user: user
    badge = create :contributor_badge

    assert badge.award_to?(user)
  end

  test "award_to for mentoring" do
    user = create :user
    create :user_mentored_reputation_token, user: user
    badge = create :contributor_badge

    assert badge.award_to?(user)
  end

  test "creates notification when created" do
    user = create :user
    badge = create :contributor_badge

    User::Notification::Create.expects(:call).with(
      user, :added_to_contributors_page, {}
    )

    User::AcquiredBadge.create!(user: user, badge: badge)
  end
end
