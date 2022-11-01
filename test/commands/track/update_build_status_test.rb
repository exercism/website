require "test_helper"

class Track::UpdateBuildStatusTest < ActiveSupport::TestCase
  test "creates new value if key does not exists" do
    track = create :track

    Track::UpdateBuildStatus.(track)

    build_status = Exercism.redis_tooling_client.get("build_status:#{track.id}")
    refute_nil build_status
    assert_equal ({}), JSON.parse(build_status)
  end
end
