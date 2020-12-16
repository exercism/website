require "test_helper"

class ProcessPushUpdateJobTest < ActiveJob::TestCase
  test "track is synced from git" do
    track = create :track, slug: 'csharp'

    Git::SyncTrack.expects(:call).with(track)
    ProcessPushUpdateJob.perform_now(track)
  end
end
