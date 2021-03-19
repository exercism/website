require "test_helper"

class SyncTrackJobTest < ActiveJob::TestCase
  test "track is synced from git" do
    track = create :track, slug: 'csharp'

    Git::SyncTrack.expects(:call).with(track)
    SyncTrackJob.perform_now(track)
  end
end
