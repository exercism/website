require "test_helper"

class User::ProfileTest < ActiveSupport::TestCase
  test "contributions_tab?" do
    user = create :user
    profile = create :user_profile, user: user
    refute profile.contributions_tab?

    create :user_published_solution_reputation_token, user: user
    refute profile.reload.contributions_tab?

    User::ReputationToken.destroy_all
    create :user_code_contribution_reputation_token, user: user
    assert profile.reload.contributions_tab?

    User::ReputationToken.destroy_all
    create :user_exercise_author_reputation_token, user: user
    assert profile.reload.contributions_tab?

    User::ReputationToken.destroy_all
    create :user_code_merge_reputation_token, user: user
    assert profile.reload.contributions_tab?

    User::ReputationToken.destroy_all
    create :user_arbitrary_reputation_token, user: user
    assert profile.reload.contributions_tab?
  end
end
