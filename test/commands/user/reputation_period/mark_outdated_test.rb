require "test_helper"

class User::ReputationPeriod::MarkOutdatedTest < ActiveSupport::TestCase
  test "adds relevant rows with track for normal tokens" do
    handle = 'ihid'
    user = create(:user, handle:)
    track = create :track
    create :user_code_contribution_reputation_token, user:, track:, earned_on: Time.zone.today

    args = { user_handle: handle, user_id: user.id, dirty: false }
    should_invalidate = [
      create(:user_reputation_period, period: :week, category: :building, about: :track, track_id: track.id, **args),
      create(:user_reputation_period, period: :week, category: :any, about: :track, track_id: track.id, **args),
      create(:user_reputation_period, period: :week, category: :building, about: :everything, **args),
      create(:user_reputation_period, period: :week, category: :any, about: :everything, **args)
    ]

    should_not_invalidate = [
      create(:user_reputation_period, period: :forever, category: :building, about: :track, track_id: track.id, **args),
      create(:user_reputation_period, period: :year, category: :building, about: :track, track_id: track.id, **args),
      create(:user_reputation_period, period: :month, category: :building, about: :track, track_id: track.id, **args),
      create(:user_reputation_period, period: :forever, category: :any, about: :track, track_id: track.id, **args),
      create(:user_reputation_period, period: :year, category: :any, about: :track, track_id: track.id, **args),
      create(:user_reputation_period, period: :month, category: :any, about: :track, track_id: track.id, **args),
      create(:user_reputation_period, period: :forever, category: :building, about: :everything, **args),
      create(:user_reputation_period, period: :year, category: :building, about: :everything, **args),
      create(:user_reputation_period, period: :month, category: :building, about: :everything, **args),
      create(:user_reputation_period, period: :forever, category: :any, about: :everything, **args),
      create(:user_reputation_period, period: :year, category: :any, about: :everything, **args),
      create(:user_reputation_period, period: :month, category: :any, about: :everything, **args)
    ]

    User::ReputationPeriod::MarkOutdated.(period: 'week', earned_on: Time.zone.today)

    assert(should_invalidate.map(&:reload).all? { |r| r.dirty? }) # rubocop:disable Style/SymbolProc
    refute(should_not_invalidate.map(&:reload).any? { |r| r.dirty? }) # rubocop:disable Style/SymbolProc
  end

  test "adds relevant rows without track" do
    user = create :user
    token = create :user_code_contribution_reputation_token, user:, earned_on: Time.zone.today
    refute token.track # Sanity

    args = { user_id: user.id, dirty: false }

    should_invalidate = [
      create(:user_reputation_period, period: :week, category: :building, about: :everything, **args),
      create(:user_reputation_period, period: :week, category: :any, about: :everything, **args)
    ]

    should_not_invalidate = [
      create(:user_reputation_period, period: :forever, category: :building, about: :everything, **args),
      create(:user_reputation_period, period: :year, category: :building, about: :everything, **args),
      create(:user_reputation_period, period: :month, category: :building, about: :everything, **args),
      create(:user_reputation_period, period: :forever, category: :any, about: :everything, **args),
      create(:user_reputation_period, period: :year, category: :any, about: :everything, **args),
      create(:user_reputation_period, period: :month, category: :any, about: :everything, **args),
      create(:user_reputation_period, period: :week, category: :mentoring, about: :everything, **args)
    ]

    User::ReputationPeriod::MarkOutdated.(period: 'week', earned_on: Time.zone.today)

    assert(should_invalidate.map(&:reload).all? { |r| r.dirty? }) # rubocop:disable Style/SymbolProc
    refute(should_not_invalidate.map(&:reload).any? { |r| r.dirty? }) # rubocop:disable Style/SymbolProc
  end

  test "works for publishing" do
    handle = 'ihid'
    user = create(:user, handle:)
    track = create :track
    create :user_published_solution_reputation_token, user:, track:, earned_on: Time.zone.today

    args = { user_handle: handle, user_id: user.id, dirty: false }
    period = create(:user_reputation_period, period: :week, category: :any, about: :everything, **args)

    User::ReputationPeriod::MarkOutdated.(period: 'week', earned_on: Time.zone.today)

    assert period.reload.dirty?
  end
end
