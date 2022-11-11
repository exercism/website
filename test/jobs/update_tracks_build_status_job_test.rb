require "test_helper"

class UpdateTracksBuildStatusJobTest < ActiveJob::TestCase
  test "build status is updated for all tracks" do
    tracks = create_list(:track, 5, :random_slug)

    UpdateTracksBuildStatusJob.perform_now

    tracks.each do |track|
      refute_nil track.build_status
    end
  end

  test "prob-specs repo is updated" do
    Git::ProblemSpecifications.expects(:update!)

    UpdateTracksBuildStatusJob.perform_now
  end
end
