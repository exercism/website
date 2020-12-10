require "test_helper"

class SyncTrackJobTest < ActiveJob::TestCase
  test "track is synced" do
    track = create :track, slug: 'csharp'

    Git::SyncTrack.expects(:call).with(track)
    SyncTrackJob.perform_now(track)
  end
end
