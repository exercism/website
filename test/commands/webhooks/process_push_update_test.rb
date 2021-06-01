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

  test "should not enqueue sync push job when pushing to non-valid track" do
    create :track, slug: :ruby

    assert_enqueued_jobs 0, only: SyncTrackJob do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'problem-specs', [])
    end
  end

  test "should enqueue notify track org wide file change job when file in .appends directory has been added" do
    create :track, slug: 'ruby'

    assert_enqueued_jobs 1, only: NotifyTrackSyncerAboutTrackChangesJob do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'ruby', [
                                     { added: ['.appends/labels.yml'], removed: [], modified: [] }
                                   ])
    end
  end

  test "should enqueue notify track org wide file change job when file in .appends directory has been removed" do
    create :track, slug: 'ruby'

    assert_enqueued_jobs 1, only: NotifyTrackSyncerAboutTrackChangesJob do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'ruby', [
                                     { added: [], removed: ['.appends/issues.json'], modified: [] }
                                   ])
    end
  end

  test "should enqueue notify track org wide file change job when file in .appends directory has been modified" do
    create :track, slug: 'ruby'

    assert_enqueued_jobs 1, only: NotifyTrackSyncerAboutTrackChangesJob do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'ruby', [
                                     { added: [], removed: [], modified: ['.appends/LICENSE.md'] }
                                   ])
    end
  end

  test "should not enqueue notify track org wide file change job when no file in .appends directory was added/updated/removed" do # rubocop:disable Layout/LineLength
    create :track, slug: :ruby

    assert_enqueued_jobs 0, only: NotifyTrackSyncerAboutTrackChangesJob do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'problem-specs', [
                                     { added: ['README.md'], removed: ['GENERATORS.md'], modified: ['CONTRIBUTING.md'] }
                                   ])
    end
  end

  test "should not enqueue notify track org wide file change job when pushing to non-valid track" do
    create :track, slug: :ruby

    assert_enqueued_jobs 0, only: NotifyTrackSyncerAboutTrackChangesJob do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'problem-specs', [])
    end
  end
end
