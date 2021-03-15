require 'test_helper'

class TrackTest < ActiveSupport::TestCase
  test ".for! with model" do
    track = random_of_many(:track)
    assert_equal track, Track.for!(track)
  end

  test ".for! with id" do
    track = random_of_many(:track)
    assert_equal track, Track.for!(track.id)
  end

  test ".for! with slug" do
    track = random_of_many(:track)
    assert_equal track, Track.for!(track.slug)
  end

  test ".active scope" do
    # Create one active and one inactive track
    track = create :track, active: true
    create :track, :random_slug, active: false

    assert_equal [track], Track.active
  end

  test "to_slug" do
    track = create :track
    assert_equal track.slug, track.to_param
  end

  test "Retrieves test_regexp for track with test regex" do
    track = create :track
    assert_equal(/test/, track.test_regexp)
  end

  test "Retrieves test_regexp for track without test regex" do
    track = create :track, repo_url: TestHelpers.git_repo_url("track-naked")
    assert_equal(/[tT]est/, track.test_regexp)
  end

  test "Retrieves ignore_regexp for track with ignore regex" do
    track = create :track
    assert_equal(/[iI]gno/, track.ignore_regexp)
  end

  test "Retrieves ignore_regexp for track without ignore regex" do
    track = create :track, repo_url: TestHelpers.git_repo_url("track-naked")
    assert_equal(/[iI]gnore/, track.ignore_regexp)
  end

  test "top_10_contributors" do
    user_1 = create :user
    user_2 = create :user
    user_3 = create :user
    track = create :track

    create :user_code_contribution_reputation_token, track: track, user: user_1
    create :user_code_contribution_reputation_token, track: track, user: user_2
    create :user_code_contribution_reputation_token, track: track, user: user_2
    create :user_code_contribution_reputation_token, user: user_3

    assert_equal [user_2, user_1], track.top_10_contributors
  end

  test "num_contributors" do
    user_1 = create :user
    user_2 = create :user
    user_3 = create :user
    track = create :track

    create :user_code_contribution_reputation_token, track: track, user: user_1
    create :user_code_contribution_reputation_token, track: track, user: user_2
    create :user_code_contribution_reputation_token, track: track, user: user_2
    create :user_code_contribution_reputation_token, user: user_3

    assert_equal 2, track.num_contributors
  end
end
