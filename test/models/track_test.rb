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

  test "Retrieves test_regexp for csharp" do
    track = create :track, slug: 'csharp'
    assert_equal(/.+test[.]rb$/, track.test_regexp)
  end

  test "Retrieves test_regexp for ruby" do
    track = create :track, slug: 'ruby'
    assert_equal(/test/, track.test_regexp)
  end

  test "Retrieves ignore_regexp for csharp" do
    track = create :track, slug: 'csharp'
    assert_equal(/[iI]gnore/, track.ignore_regexp)
  end

  test "Retrieves ignore_regexp for ruby" do
    track = create :track, slug: 'ruby'
    assert_equal(/[iI]gno/, track.ignore_regexp)
  end
end
