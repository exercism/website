require "test_helper"

class Webhooks::ProcessPushUpdateTest < ActiveSupport::TestCase
  test "should enqueue sync push job when pushing to main branch" do
    create :track, slug: 'ruby'

    assert_enqueued_jobs 1, only: SyncTrackJob do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'ruby')
    end
  end

  test "should enqueue sync push job when pushing website-copy" do
    assert_enqueued_jobs 1, only: UpdateWebsiteCopyJob do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'website-copy')
    end
  end

  test "should enqueue sync push job when pushing docs" do
    assert_enqueued_jobs 1, only: SyncDocsJob do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'docs')
    end
  end

  test "should not enqueue sync push job when pushing to non-main branch" do
    create :track, slug: :ruby

    assert_enqueued_jobs 0, only: SyncTrackJob do
      Webhooks::ProcessPushUpdate.('refs/heads/develop', 'ruby')
    end
  end

  test "should not enqueue sync push job when pushing to non-valid track" do
    create :track, slug: :ruby

    assert_enqueued_jobs 0, only: SyncTrackJob do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'problem-specs')
    end
  end
end
