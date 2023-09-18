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

    generate_reputation_periods!

    data = User::ReputationToken::CalculateContextualData.(user.id)
    expected_activity = "1 PR created • 5 PRs reviewed and/or merged • 9 exercise contributions • 6 solutions mentored • 7 solutions published" # rubocop:disable Layout/LineLength
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

    generate_reputation_periods!

    data = User::ReputationToken::CalculateContextualData.(user.id, track_id: track.id)
    assert_equal "2 PRs created", data.activity
    assert_equal 24, data.reputation
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

      generate_reputation_periods!

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

      # Check missing period returns everything
      data = User::ReputationToken::CalculateContextualData.(user.id)
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

    generate_reputation_periods!

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
      generate_reputation_periods!

      # Check we call this normally
      User::ReputationPeriod.expects(:where).at_least_once.returns(User::ReputationPeriod)

      User::ReputationToken::CalculateContextualData.(user.id, period: :week)
    end
  end

  test "check we use cache" do
    freeze_time do
      user = create :user
      create :user_code_contribution_reputation_token, user:, earned_on: Time.zone.today

      generate_reputation_periods!

      data = User::ReputationToken::CalculateContextualData.(user.id, period: :week)
      assert_equal "1 PR created", data.activity
      assert_equal 12, data.reputation

      # Check this isn't called again!
      User::ReputationPeriod.expects(:where).never

      data = User::ReputationToken::CalculateContextualData.(user.id, period: :week)
      assert_equal "1 PR created", data.activity
      assert_equal 12, data.reputation
    end
  end

  test "check 0 reputation is not cached" do
    user = create :user

    ActiveRecord::Relation.any_instance.expects(:sum).with(:num_tokens).at_least_once.returns({})

    ActiveRecord::Relation.any_instance.expects(:sum).with(:reputation).returns(0)
    data = User::ReputationToken::CalculateContextualData.(user.id, period: :week)
    assert_equal 0, data.reputation

    # This time it should be cached with 10
    ActiveRecord::Relation.any_instance.expects(:sum).with(:reputation).returns(10)
    data = User::ReputationToken::CalculateContextualData.(user.id, period: :week)
    assert_equal 10, data.reputation

    # So we shouldn't look it up next time
    ActiveRecord::Relation.any_instance.expects(:sum).never
    data = User::ReputationToken::CalculateContextualData.(user.id, period: :week)
    assert_equal 10, data.reputation
  end

  test "check cache is invalidated when a new token is created" do
    freeze_time do
      user = create :user
      create :user_code_contribution_reputation_token, user:, earned_on: Time.zone.today
      generate_reputation_periods!

      data = User::ReputationToken::CalculateContextualData.(user.id, period: :week)
      assert_equal "1 PR created", data.activity
      assert_equal 12, data.reputation

      # Create a second token
      create :user_code_contribution_reputation_token, user:, earned_on: Time.zone.today
      generate_reputation_periods!

      data = User::ReputationToken::CalculateContextualData.(user.id, period: :week)
      assert_equal "2 PRs created", data.activity
      assert_equal 24, data.reputation
    end
  end
end
