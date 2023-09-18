require "test_helper"

class Badge::ContributorBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :contributor_badge
    assert_equal "Contributor", badge.name
    assert_equal :ultimate, badge.rarity
    assert_equal :contributors, badge.icon
    assert_equal 'Contributed to Exercism', badge.description
    refute badge.send_email_on_acquisition?
    assert_equal :added_to_contributors_page, badge.notification_key
  end

  test "award_to for publishing doesn't count" do
    user = create :user
    create(:user_published_solution_reputation_token, user:)
    badge = create :contributor_badge

    refute badge.award_to?(user)
  end

  test "award_to for building" do
    user = create :user
    create(:user_code_contribution_reputation_token, user:)
    badge = create :contributor_badge

    assert badge.award_to?(user)
  end

  test "award_to for maintaining" do
    user = create :user
    create(:user_code_merge_reputation_token, user:)
    badge = create :contributor_badge

    assert badge.award_to?(user)
  end

  test "award_to for authoring" do
    user = create :user
    create(:user_exercise_author_reputation_token, user:)
    badge = create :contributor_badge

    assert badge.award_to?(user)
  end

  test "award_to for mentoring" do
    user = create :user
    create(:user_mentored_reputation_token, user:)
    badge = create :contributor_badge

    assert badge.award_to?(user)
  end

  test "worth_queuing?" do
    # category: misc
    refute Badges::ContributorBadge.worth_queuing?(reputation_token: create(:user_arbitrary_reputation_token))

    # category: publishing
    refute Badges::ContributorBadge.worth_queuing?(reputation_token: create(:user_published_solution_reputation_token))

    # category: building
    assert Badges::ContributorBadge.worth_queuing?(reputation_token: create(:user_code_contribution_reputation_token))

    # category: maintaining
    assert Badges::ContributorBadge.worth_queuing?(reputation_token: create(:user_code_merge_reputation_token))

    # category: mentoring
    assert Badges::ContributorBadge.worth_queuing?(reputation_token: create(:user_mentored_reputation_token))

    # category: authoring
    assert Badges::ContributorBadge.worth_queuing?(reputation_token: create(:user_exercise_author_reputation_token))
  end
end
