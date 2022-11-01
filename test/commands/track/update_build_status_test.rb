require "test_helper"

class Track::UpdateBuildStatusTest < ActiveSupport::TestCase
  test "creates entry if key does not exists" do
    redis = Exercism.redis_tooling_client
    track = create :track

    # Sanity check
    assert 0, redis.exists(track.build_status_key)

    Track::UpdateBuildStatus.(track)

    assert 1, redis.exists(track.build_status_key)
  end

  test "updates entry if key exists" do
    redis = Exercism.redis_tooling_client
    track = create :track
    Track::UpdateBuildStatus.(track)

    # Sanity check
    assert_equal 0, JSON.parse(redis.get(track.build_status_key)).dig("students", "count")

    track.update(num_students: 33)
    Track::UpdateBuildStatus.(track)

    assert_equal 33, JSON.parse(redis.get(track.build_status_key)).dig("students", "count")
  end
end
