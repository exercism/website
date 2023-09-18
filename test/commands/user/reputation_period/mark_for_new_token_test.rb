require "test_helper"

class User::ReputationPeriod::MarkForTokenTest < ActiveSupport::TestCase
  test "adds relevant rows with track for normal tokens" do
    handle = 'ihid'
    user = create(:user, handle:)
    track = create :track
    token = create(:user_code_contribution_reputation_token, user:, track:)

    User::ReputationPeriod::MarkForToken.(token)

    args = { user_handle: handle, user_id: user.id, dirty: true }

    assert_equal 16, User::ReputationPeriod.count

    assert User::ReputationPeriod.where(period: :forever, category: :building, about: :track, track_id: track.id,
                                        **args).exists?
    assert User::ReputationPeriod.where(period: :year, category: :building, about: :track, track_id: track.id,
                                        **args).exists?
    assert User::ReputationPeriod.where(period: :month, category: :building, about: :track, track_id: track.id,
                                        **args).exists?
    assert User::ReputationPeriod.where(period: :week, category: :building, about: :track, track_id: track.id,
                                        **args).exists?

    assert User::ReputationPeriod.where(period: :forever, category: :any, about: :track, track_id: track.id, **args).exists?
    assert User::ReputationPeriod.where(period: :year, category: :any, about: :track, track_id: track.id, **args).exists?
    assert User::ReputationPeriod.where(period: :month, category: :any, about: :track, track_id: track.id, **args).exists?
    assert User::ReputationPeriod.where(period: :week, category: :any, about: :track, track_id: track.id, **args).exists?

    assert User::ReputationPeriod.where(period: :forever, category: :building, about: :everything, **args).exists?
    assert User::ReputationPeriod.where(period: :year, category: :building, about: :everything, **args).exists?
    assert User::ReputationPeriod.where(period: :month, category: :building, about: :everything, **args).exists?
    assert User::ReputationPeriod.where(period: :week, category: :building, about: :everything, **args).exists?

    assert User::ReputationPeriod.where(period: :forever, category: :any, about: :everything, **args).exists?
    assert User::ReputationPeriod.where(period: :year, category: :any, about: :everything, **args).exists?
    assert User::ReputationPeriod.where(period: :month, category: :any, about: :everything, **args).exists?
    assert User::ReputationPeriod.where(period: :week, category: :any, about: :everything, **args).exists?
  end

  test "adds relevant rows without track" do
    handle = 'ihid'
    user = create(:user, handle:)
    token = create(:user_code_contribution_reputation_token, user:)
    refute token.track # Sanity

    User::ReputationPeriod::MarkForToken.(token)

    args = { user_handle: handle, user_id: user.id, dirty: true }

    assert_equal 8, User::ReputationPeriod.count

    assert User::ReputationPeriod.where(period: :forever, category: :building, about: :everything, **args).exists?
    assert User::ReputationPeriod.where(period: :year, category: :building, about: :everything, **args).exists?
    assert User::ReputationPeriod.where(period: :month, category: :building, about: :everything, **args).exists?
    assert User::ReputationPeriod.where(period: :week, category: :building, about: :everything, **args).exists?

    assert User::ReputationPeriod.where(period: :forever, category: :any, about: :everything, **args).exists?
    assert User::ReputationPeriod.where(period: :year, category: :any, about: :everything, **args).exists?
    assert User::ReputationPeriod.where(period: :month, category: :any, about: :everything, **args).exists?
    assert User::ReputationPeriod.where(period: :week, category: :any, about: :everything, **args).exists?
  end

  test "does not create category rows for publishing" do
    handle = 'ihid'
    user = create(:user, handle:)
    track = create :track
    token = create(:user_published_solution_reputation_token, user:, track:)

    User::ReputationPeriod::MarkForToken.(token)

    refute User::ReputationPeriod.where.not(category: :any).exists?
    assert_equal 8, User::ReputationPeriod.where(category: :any).count
    assert_equal 8, User::ReputationPeriod.count
  end
end
