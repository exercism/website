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
    create(:user_code_contribution_reputation_token, user:)
    2.times { create :user_code_merge_reputation_token, user: }
    3.times { create :user_code_review_reputation_token, user: }
    4.times { create :user_exercise_author_reputation_token, user: }
    5.times { create :user_exercise_contribution_reputation_token, user: }
    6.times { create :user_mentored_reputation_token, user: }
    7.times { create :user_published_solution_reputation_token, user: }
    data = User::ReputationToken::CalculateContextualData.(user.id)
    expected_activity = "1 PR created • 3 PRs reviewed • 2 PRs merged • 4 exercises authored • 5 exercise contributions • 6 solutions mentored • 7 solutions published" # rubocop:disable Layout/LineLength
    assert_equal expected_activity, data.activity
    assert_equal 203, data.reputation
  end

  test "filters track correctly" do
    user = create :user
    track = create :track, slug: :js
    create(:user_code_contribution_reputation_token, user:, track:)
    create(:user_code_contribution_reputation_token, user:, track:)
    create :user_code_contribution_reputation_token, user:, track: create(:track)
    create :user_code_contribution_reputation_token, user:, track: nil

    data = User::ReputationToken::CalculateContextualData.(user.id, track_id: track.id)
    assert_equal "2 PRs created", data.activity
    assert_equal 24, data.reputation
  end

  test "filters earned_since correctly" do
    freeze_time do
      user = create :user
      create :user_code_contribution_reputation_token, user:, earned_on: Time.zone.today
      create :user_code_contribution_reputation_token, user:, earned_on: Time.zone.today - 1.day
      create :user_code_contribution_reputation_token, user:, earned_on: Time.zone.today - 2.days
      create :user_code_contribution_reputation_token, user:, earned_on: Time.zone.today - 3.days

      data = User::ReputationToken::CalculateContextualData.(user.id, earned_since: Time.zone.today)
      assert_equal "1 PR created", data.activity
      assert_equal 12, data.reputation

      data = User::ReputationToken::CalculateContextualData.(user.id, earned_since: Time.zone.today - 2.days)
      assert_equal "3 PRs created", data.activity
      assert_equal 36, data.reputation
    end
  end

  test "filters period correctly" do
    freeze_time do
      user = create :user
      create :user_code_contribution_reputation_token, user:, earned_on: Time.zone.today
      create :user_code_contribution_reputation_token, user:, earned_on: Time.zone.today - 6.days
      create :user_code_contribution_reputation_token, user:, earned_on: Time.zone.today - 7.days
      create :user_code_contribution_reputation_token, user:, earned_on: Time.zone.today - 29.days
      create :user_code_contribution_reputation_token, user:, earned_on: Time.zone.today - 30.days
      create :user_code_contribution_reputation_token, user:, earned_on: Time.zone.today - 31.days
      create :user_code_contribution_reputation_token, user:, earned_on: Time.zone.today - 364.days
      create :user_code_contribution_reputation_token, user:, earned_on: Time.zone.today - 365.days

      data = User::ReputationToken::CalculateContextualData.(user.id, period: :week)
      assert_equal "2 PRs created", data.activity
      assert_equal 24, data.reputation

      # Check we can handle a string
      data = User::ReputationToken::CalculateContextualData.(user.id, period: 'week')
      assert_equal "2 PRs created", data.activity
      assert_equal 24, data.reputation

      data = User::ReputationToken::CalculateContextualData.(user.id, period: :month)
      assert_equal "4 PRs created", data.activity
      assert_equal 48, data.reputation

      data = User::ReputationToken::CalculateContextualData.(user.id, period: :year)
      assert_equal "7 PRs created", data.activity
      assert_equal 84, data.reputation

      # Check unexpected period returns everything
      data = User::ReputationToken::CalculateContextualData.(user.id, period: :misc)
      assert_equal "8 PRs created", data.activity
      assert_equal 96, data.reputation
    end
  end

  test "filters category correctly" do
    user = create :user
    create(:user_code_contribution_reputation_token, user:)
    create(:user_code_merge_reputation_token, user:)
    create(:user_code_review_reputation_token, user:)
    create(:user_exercise_author_reputation_token, user:)
    create(:user_exercise_contribution_reputation_token, user:)
    create(:user_published_solution_reputation_token, user:)
    3.times { create :user_mentored_reputation_token, user: }

    data = User::ReputationToken::CalculateContextualData.(user.id, category: :building)
    assert_equal "1 PR created", data.activity
    assert_equal 12, data.reputation

    data = User::ReputationToken::CalculateContextualData.(user.id, category: :mentoring)
    assert_equal "3 solutions mentored", data.activity
    assert_equal 15, data.reputation
  end

  test "check we use activerecord select_all (for cache check below)" do
    freeze_time do
      user = create :user
      create :user_code_contribution_reputation_token, user:, earned_on: Time.zone.today

      ActiveRecord::Base.connection.expects(:select_all).once.returns([])
      User::ReputationToken::CalculateContextualData.(user.id, period: :week)
    end
  end

  test "check we use cache" do
    freeze_time do
      user = create :user
      create :user_code_contribution_reputation_token, user:, earned_on: Time.zone.today

      data = User::ReputationToken::CalculateContextualData.(user.id, period: :week)
      assert_equal "1 PR created", data.activity
      assert_equal 12, data.reputation

      ActiveRecord::Base.connection.expects(:select_all).never

      data = User::ReputationToken::CalculateContextualData.(user.id, period: :week)
      assert_equal "1 PR created", data.activity
      assert_equal 12, data.reputation
    end
  end

  test "check cache is invalidated when a new token is created" do
    freeze_time do
      user = create :user
      create :user_code_contribution_reputation_token, user:, earned_on: Time.zone.today

      data = User::ReputationToken::CalculateContextualData.(user.id, period: :week)
      assert_equal "1 PR created", data.activity
      assert_equal 12, data.reputation

      # Create a second token
      create :user_code_contribution_reputation_token, user:, earned_on: Time.zone.today

      data = User::ReputationToken::CalculateContextualData.(user.id, period: :week)
      assert_equal "2 PRs created", data.activity
      assert_equal 24, data.reputation
    end
  end
end
