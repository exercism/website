require "test_helper"

class User::ReputationPeriod::UpdateReputationTest < ActiveSupport::TestCase
  test "recalculates everything row" do
    user = create :user
    value = 3.times.sum do
      create(:user_code_contribution_reputation_token, user:).value
    end

    # Random other token
    create :user_code_contribution_reputation_token

    period = create(:user_reputation_period, :dirty, user:)

    User::ReputationPeriod::UpdateReputation.(period)

    assert_equal value, period.reload.reputation
  end

  test "deletes rows if the only token is publishing" do
    user = create :user
    create(:user_published_solution_reputation_token, user:)
    period = create(:user_reputation_period, :dirty, user:)

    User::ReputationPeriod::UpdateReputation.(period)

    assert_raises ActiveRecord::RecordNotFound do
      period.reload
    end
  end

  test "deletes rows if reputation ends at zero" do
    period = create :user_reputation_period, :dirty

    User::ReputationPeriod::UpdateReputation.(period)

    assert_raises ActiveRecord::RecordNotFound do
      period.reload
    end
  end

  test "recalculates track period correctly" do
    user = create :user
    track = create :track, slug: :js

    tokens = Array.new(3) { create :user_reputation_token, user:, track_id: track.id }

    # Create different track token
    create :user_reputation_token, user:, track_id: create(:track).id

    period = create :user_reputation_period, :dirty, user:, about: :track, track_id: track.id

    User::ReputationPeriod::UpdateReputation.(period)

    assert_equal tokens.sum(&:value), period.reload.reputation
  end

  test "recalculates time periods correctly" do
    user = create :user
    create :user_reputation_token, user:, earned_on: Date.current - 6.days
    create :user_reputation_token, user:, earned_on: Date.current - 7.days
    create :user_reputation_token, user:, earned_on: Date.current - 33.days
    create :user_reputation_token, user:, earned_on: Date.current - 364.days
    create :user_reputation_token, user:, earned_on: Date.current - 365.days

    forever_period = create :user_reputation_period, :dirty, user:, period: :forever
    year_period = create :user_reputation_period, :dirty, user:, period: :year
    month_period = create :user_reputation_period, :dirty, user:, period: :month
    weeky_period = create :user_reputation_period, :dirty, user:, period: :week

    # Process them all
    User::ReputationPeriod::Sweep.()

    assert_equal 60, forever_period.reload.reputation
    assert_equal 48, year_period.reload.reputation
    assert_equal 24, month_period.reload.reputation
    assert_equal 12, weeky_period.reload.reputation
  end

  test "recalculates categories correctly" do
    user = create :user
    create(:user_code_contribution_reputation_token, user:)
    create(:user_code_merge_reputation_token, user:)
    create(:user_exercise_author_reputation_token, user:)
    create(:user_mentored_reputation_token, user:)
    create(:user_published_solution_reputation_token, user:)

    any_period = create :user_reputation_period, :dirty, user:, category: :any
    building_period = create :user_reputation_period, :dirty, user:, category: :building
    maintaining_period = create :user_reputation_period, :dirty, user:, category: :maintaining
    authoring_period = create :user_reputation_period, :dirty, user:, category: :authoring
    mentoring_period = create :user_reputation_period, :dirty, user:, category: :mentoring

    # Process them all
    User::ReputationPeriod::Sweep.()

    assert_equal 40, any_period.reload.reputation
    assert_equal 12, building_period.reload.reputation
    assert_equal 1, maintaining_period.reload.reputation
    assert_equal 20, authoring_period.reload.reputation
    assert_equal 5, mentoring_period.reload.reputation
  end

  test "insiders_status is updated" do
    user = create :user, reputation: 0

    token = create(:user_code_contribution_reputation_token, level: :large, user:)
    period = create(:user_reputation_period, :dirty, user:, period: :month, category: :building)

    perform_enqueued_jobs do
      User::ReputationPeriod::UpdateReputation.(period)
      assert_equal :eligible, user.reload.insiders_status

      token.destroy
      period.update(dirty: true)
      User::ReputationPeriod::UpdateReputation.(period)
      assert_equal :ineligible, user.reload.insiders_status
    end
  end
end
