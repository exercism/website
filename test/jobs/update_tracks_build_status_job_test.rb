require "test_helper"

class UpdateTracksBuildStatusJobTest < ActiveJob::TestCase
  test "build status is updated for all tracks" do
    tracks = create_list(:track, 5, :random_slug)

    UpdateTracksBuildStatusJob.perform_now

    tracks.each do |track|
      assert 1, Exercism.redis_tooling_client.exists(track.build_status_key)
    end
  end
end
