require "test_helper"

class Webhooks::ProcessRepoUpdateTest < ActiveSupport::TestCase
  test "should enqueue track sync job when pushing to master branch" do
    track = create :track, slug: 'csharp'

    Webhooks::ProcessRepoUpdate.('refs/heads/master', 'csharp')

    assert_enqueued_jobs 1, only: SyncTrackJob do
      SyncTrackJob.perform_later(track)
    end
  end

  test "should not enqueue track sync job when pushing to non-master branch" do
    Webhooks::ProcessRepoUpdate.('refs/heads/develop', 'csharp')

    assert_enqueued_jobs 0, only: SyncTrackJob
  end
end
