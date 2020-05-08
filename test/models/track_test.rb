require 'test_helper'

class TrackTest < ActiveSupport::TestCase
  test "#for! with model" do
    track = random_of_many(:track)
    assert_equal track, Track.for!(track)
  end

  test "#for! with id" do
    track = random_of_many(:track)
    assert_equal track, Track.for!(track.id)
  end

  test "#for! with slug" do
    track = random_of_many(:track)
    assert_equal track, Track.for!(track.slug)
  end
end
