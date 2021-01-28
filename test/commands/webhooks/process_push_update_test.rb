require "test_helper"

class Webhooks::ProcessPushUpdateTest < ActiveSupport::TestCase
  test "should enqueue sync push job when pushing to main branch" do
    track = create :track, slug: 'csharp'

    Webhooks::ProcessPushUpdate.('refs/heads/main', 'csharp')

    assert_enqueued_jobs 1, only: ProcessPushUpdateJob do
      ProcessPushUpdateJob.perform_later(track)
    end
  end

  test "should not enqueue sync push job when pushing to non-main branch" do
    Webhooks::ProcessPushUpdate.('refs/heads/develop', 'csharp')

    assert_enqueued_jobs 0, only: ProcessPushUpdateJob
  end
end
