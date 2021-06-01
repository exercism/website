require "test_helper"

class Webhooks::ProcessPushUpdateTest < ActiveSupport::TestCase
  test "should enqueue sync push job when pushing to main branch" do
    create :track, slug: 'ruby'

    assert_enqueued_jobs 1, only: SyncTrackJob do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'ruby', [])
    end
  end

  test "should enqueue sync push job when pushing website-copy" do
    assert_enqueued_jobs 1, only: UpdateWebsiteCopyJob do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'website-copy', [])
    end
  end

  test "should enqueue sync push job when pushing docs" do
    assert_enqueued_jobs 1, only: SyncDocsJob do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'docs', [])
    end
  end

  test "should not enqueue sync push job when pushing to non-main branch" do
    create :track, slug: :ruby

    assert_enqueued_jobs 0, only: SyncTrackJob do
      Webhooks::ProcessPushUpdate.('refs/heads/develop', 'ruby', [])
    end
  end

  test "should not enqueue sync push job when pushing to non-track repo" do
    create :track, slug: :ruby

    assert_enqueued_jobs 0, only: SyncTrackJob do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'problem-specs', [])
    end
  end

  test "should notify track syncer when commit contains added file in .appends directory" do
    track = create :track, slug: 'ruby'

    Github::NotifyTrackSyncerAboutTrackChanges.expects(:call).with(track)

    Webhooks::ProcessPushUpdate.('refs/heads/main', 'ruby', [
                                   { added: ['.appends/labels.yml'], removed: [], modified: [] }
                                 ])
  end

  test "should notify track syncer when commit contains removed file from .appends directory" do
    track = create :track, slug: 'ruby'

    Github::NotifyTrackSyncerAboutTrackChanges.expects(:call).with(track)

    Webhooks::ProcessPushUpdate.('refs/heads/main', 'ruby', [
                                   { added: [], removed: ['.appends/issues.json'], modified: [] }
                                 ])
  end

  test "should notify track syncer when commit contains modified file in .appends directory" do
    track = create :track, slug: 'ruby'

    Github::NotifyTrackSyncerAboutTrackChanges.expects(:call).with(track)

    Webhooks::ProcessPushUpdate.('refs/heads/main', 'ruby', [
                                   { added: [], removed: [], modified: ['.appends/LICENSE.md'] }
                                 ])
  end

  test "should not notify track syncer when commit does not contain modified file in .appends directory" do
    create :track, slug: :ruby

    Github::NotifyTrackSyncerAboutTrackChanges.expects(:call).never

    Webhooks::ProcessPushUpdate.('refs/heads/main', 'ruby', [
                                   { added: ['README.md'], removed: ['GENERATORS.md'], modified: ['CONTRIBUTING.md'] }
                                 ])
  end

  test "should not notify track syncer when pushing to non-track repo" do
    Github::NotifyTrackSyncerAboutTrackChanges.expects(:call).never

    Webhooks::ProcessPushUpdate.('refs/heads/main', 'problem-specs', [])
  end
end
