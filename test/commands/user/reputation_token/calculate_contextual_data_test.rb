require 'test_helper'

class User::ReputationToken::CalculateContextualDataTest < ActiveSupport::TestCase
  test "handles no data" do
    user = create :user
    data = User::ReputationToken::CalculateContextualData.(user.id)
    assert_equal "", data.activity
    assert_equal 0, data.reputation
  end

  test "calculates data correctly" do
    user = create :user
    create :user_code_contribution_reputation_token, user: user
    2.times { create :user_code_merge_reputation_token, user: user }
    3.times { create :user_code_review_reputation_token, user: user }
    4.times { create :user_exercise_author_reputation_token, user: user }
    5.times { create :user_exercise_contribution_reputation_token, user: user }
    6.times { create :user_mentored_reputation_token, user: user }
    7.times { create :user_published_solution_reputation_token, user: user }
    data = User::ReputationToken::CalculateContextualData.(user.id)
    expected_activity = "1 PR created • 3 PRs reviewed • 2 PRs merged • 4 exercises authored • 5 exercise contributions • 6 solutions mentored • 7 solutions published" # rubocop:disable Layout/LineLength
    assert_equal expected_activity, data.activity
    assert_equal 203, data.reputation
  end
end
