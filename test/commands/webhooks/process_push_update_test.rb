require "test_helper"

class Webhooks::ProcessPushUpdateTest < ActiveSupport::TestCase
  test "should enqueue sync push job when pushing to main branch" do
    create :track, slug: 'ruby'

    assert_enqueued_jobs 1, only: SyncTrackJob do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'ruby', 'user17', [])
    end
  end

  test "should enqueue sync push job when pushing website-copy" do
    assert_enqueued_jobs 1, only: UpdateWebsiteCopyJob do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'website-copy', 'user17', [])
    end
  end

  test "should enqueue sync push job when pushing docs" do
    assert_enqueued_jobs 1, only: SyncDocsJob do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'docs', 'user17', [])
    end
  end

  test "should not enqueue sync push job when pushing to non-main branch" do
    create :track, slug: :ruby

    assert_enqueued_jobs 0, only: SyncTrackJob do
      Webhooks::ProcessPushUpdate.('refs/heads/develop', 'exercism', 'ruby', 'user17', [])
    end
  end

  test "should not enqueue sync push job when pushing to non-track repo" do
    create :track, slug: :ruby

    assert_enqueued_jobs 0, only: SyncTrackJob do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'problem-specs', 'user17', [])
    end
  end

  test "should dispatch org-wide-files event when commit contains added file in .appends directory" do
    Github::DispatchEventToOrgWideFilesRepo.expects(:call).with(:appends_update, ['exercism/ruby'], 'user17')

    Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'ruby', 'user17', [
                                   { added: ['.appends/labels.yml'], removed: [], modified: [] }
                                 ])
  end

  test "should dispatch org-wide-files event when commit contains removed file from .appends directory" do
    Github::DispatchEventToOrgWideFilesRepo.expects(:call).with(:appends_update, ['exercism/website'], 'user17')

    Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'website', 'user17', [
                                   { added: [], removed: ['.appends/issues.json'], modified: [] }
                                 ])
  end

  test "should dispatch org-wide-files event when commit contains modified file in .appends directory" do
    Github::DispatchEventToOrgWideFilesRepo.expects(:call).with(:appends_update, ['exercism/configlet'], 'user17')

    Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'configlet', 'user17', [
                                   { added: [], removed: [], modified: ['.appends/LICENSE.md'] }
                                 ])
  end

  test "should not dispatch org-wide-files event when commit does not contain modified file in .appends directory" do
    Github::DispatchEventToOrgWideFilesRepo.expects(:call).never

    Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'ruby', 'user17', [
                                   { added: ['README.md'], removed: ['GENERATORS.md'], modified: ['CONTRIBUTING.md'] }
                                 ])
  end
end
