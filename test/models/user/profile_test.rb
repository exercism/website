require "test_helper"

class User::ProfileTest < ActiveSupport::TestCase
  test "contributions_tab?" do
    user = create :user
    profile = create(:user_profile, user:)
    refute profile.contributions_tab?

    create(:user_published_solution_reputation_token, user:)
    refute profile.reload.contributions_tab?

    User::ReputationToken.destroy_all
    create(:user_code_contribution_reputation_token, user:)
    assert profile.reload.contributions_tab?

    User::ReputationToken.destroy_all
    create(:user_exercise_author_reputation_token, user:)
    assert profile.reload.contributions_tab?

    User::ReputationToken.destroy_all
    create(:user_code_merge_reputation_token, user:)
    assert profile.reload.contributions_tab?

    User::ReputationToken.destroy_all
    create(:user_arbitrary_reputation_token, user:)
    assert profile.reload.contributions_tab?
  end

  test "badges_tab?" do
    user = create :user
    profile = create(:user_profile, user:)
    refute profile.badges_tab?

    create :user_acquired_badge, user:, badge: create(:rookie_badge), revealed: false
    refute profile.reload.badges_tab?

    create :user_acquired_badge, user:, badge: create(:member_badge), revealed: true
    assert profile.reload.badges_tab?
  end
end
