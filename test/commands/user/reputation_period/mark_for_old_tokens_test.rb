require "test_helper"

class User::ReputationPeriod::MarkOutdatedTest < ActiveSupport::TestCase
  test "test marks for week with track" do
    travel_to Date.new(2021, 1, 5)

    user = create :user
    track = create :track

    token_1 = create :user_code_contribution_reputation_token, user:, track:, earned_on: Date.new(2021, 1, 1)
    token_2 = create :user_code_contribution_reputation_token, user:, track:, earned_on: Date.new(2021, 1, 2)
    token_3 = create :user_code_contribution_reputation_token, user:, track:, earned_on: Date.new(2021, 1, 3)

    # Create all the relevant records
    User::ReputationPeriod::MarkForToken.(token_1)
    User::ReputationPeriod::MarkForToken.(token_2)
    User::ReputationPeriod::MarkForToken.(token_3)
    User::ReputationPeriod::Sweep.()

    assert_equal 16, User::ReputationPeriod.count # Sanity
    refute User::ReputationPeriod.dirty.exists?

    User::ReputationPeriod::MarkOutdated.(period: :week, earned_on: Date.new(2021, 1, 3))
    assert_equal 16, User::ReputationPeriod.count # Sanity
    assert_equal 4, User::ReputationPeriod.dirty.count
    assert_equal ['week'], User::ReputationPeriod.dirty.pluck(:period).uniq
  end

  test "test marks for week without track" do
    travel_to Date.new(2021, 1, 5)

    user = create :user

    token_1 = create :user_code_contribution_reputation_token, user:, earned_on: Date.new(2021, 1, 1)
    token_2 = create :user_code_contribution_reputation_token, user:, earned_on: Date.new(2021, 1, 2)
    token_3 = create :user_code_contribution_reputation_token, user:, earned_on: Date.new(2021, 1, 3)

    # Create all the relevant records
    User::ReputationPeriod::MarkForToken.(token_1)
    User::ReputationPeriod::MarkForToken.(token_2)
    User::ReputationPeriod::MarkForToken.(token_3)
    User::ReputationPeriod::Sweep.()

    assert_equal 8, User::ReputationPeriod.count # Sanity
    refute User::ReputationPeriod.dirty.exists?

    User::ReputationPeriod::MarkOutdated.(period: :week, earned_on: Date.new(2021, 1, 3))
    assert_equal 8, User::ReputationPeriod.count # Sanity
    assert_equal 2, User::ReputationPeriod.dirty.count
    assert_equal ['week'], User::ReputationPeriod.dirty.pluck(:period).uniq
  end

  test "only updates each record once" do
    travel_to Date.new(2021, 1, 5)
    user = create :user

    token_1 = create :user_reputation_token, user:, earned_on: Date.new(2021, 1, 1)
    token_2 = create :user_reputation_token, user:, earned_on: Date.new(2021, 1, 1)

    # Create all the relevant records
    User::ReputationPeriod::MarkForToken.(token_1)
    User::ReputationPeriod::MarkForToken.(token_2)
    User::ReputationPeriod::Sweep.()

    assert_equal 2, User::ReputationToken.count # Sanity
    assert_equal 8, User::ReputationPeriod.count # Sanity

    # This would run twice for each token (so four times) in a naive implementation
    [
      { category: :any, about: :everything, track_id: 0, user_id: user.id, period: :week },
      { category: :building, about: :everything, track_id: 0, user_id: user.id, period: :week }
    ].each do |params|
      User::ReputationPeriod.expects(:where).with(params).returns(mock(update_all: nil))
    end

    User::ReputationPeriod::MarkOutdated.(period: :week, earned_on: Date.new(2021, 1, 1))
  end
end
