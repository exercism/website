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
    create :track, active: false

    assert_equal [track], Track.active
  end

  test "Retrieves test_regexp" do
    track = create :track, test_pattern: "test"
    assert_equal(/test/, track.test_regexp)
  end

  test "Has correct default test_regexp" do
    track = create :track, test_pattern: ""
    assert_equal(/[tT]est/, track.test_regexp)
  end

  test "Retrieves ignore_regexp" do
    track = create :track, ignore_pattern: "[iI]gno"
    assert_equal(/[iI]gno/, track.ignore_regexp)
  end

  test "Has correct default ignore_regexp" do
    track = create :track, ignore_pattern: ""
    assert_equal(/[iI]gnore/, track.ignore_regexp)
  end
end
