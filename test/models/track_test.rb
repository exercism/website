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

  test ".active scope" do
    # Create one active and one inactive track
    track = create :track, active: true
    create :track, active: false

    assert_equal [track], Track.active
  end

  %w[head_sha].each do |delegate|
    test "delegates git_#{delegate}" do
      slug = SecureRandom.uuid
      url = TestHelpers.git_repo_url("track-with-exercises")
      git_track = Git::Track.new(url, slug)
      track = create :track, repo_url: url, slug: slug
      assert_equal git_track.send(delegate), track.send("git_#{delegate}")
    end
  end
end
