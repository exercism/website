require "test_helper"

class Webhooks::ProcessPushUpdateTest < ActiveSupport::TestCase
  test "should enqueue sync track job when pushing to main branch" do
    track = create :track, slug: 'ruby'

    assert_enqueued_with job: MandateJob, args: [Git::SyncTrack.name, track] do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'ruby', 'user17', [], false)
    end
  end

  test "should enqueue update website copy job when pushing website-copy" do
    assert_enqueued_with job: UpdateWebsiteCopyJob do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'website-copy', 'user17', [], false)
    end
  end

  test "should enqueue sync main docs job when pushing docs" do
    assert_enqueued_with job: MandateJob, args: [Git::SyncMainDocs.name] do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'docs', 'user17', [], false)
    end
  end

  test "should enqueue sync blog job when pushing blog" do
    assert_enqueued_with job: MandateJob, args: [Git::SyncBlog.name] do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'blog', 'user17', [], false)
    end
  end

  test "should enqueue sync problem-specifications job when pushing problem-specifications" do
    assert_enqueued_with job: MandateJob, args: [Git::SyncProblemSpecifications.name] do
      Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'problem-specifications', 'user17', [], false)
    end
  end

  test "should not enqueue sync track job when pushing to non-main branch" do
    create :track, slug: :ruby

    assert_no_enqueued_jobs only: MandateJob do
      Webhooks::ProcessPushUpdate.('refs/heads/develop', 'exercism', 'ruby', 'user17', [], false)
    end
  end

  test "should not enqueue sync track job when pushing to non-track repo" do
    create :track, slug: :ruby

    Git::SyncTrack.expects(:defer).never

    Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'problem-specs', 'user17', [], false)
  end

  test "should dispatch backup repo event" do
    Github::DispatchBackupRepoEvent.expects(:defer).with('ruby')

    Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'ruby', 'user17', [], false)
  end

  test "should dispatch org-wide-files event when commit contains added file in .appends directory" do
    Github::DispatchOrgWideFilesRepoUpdateEvent.expects(:defer).with('exercism/ruby', 'user17')

    Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'ruby', 'user17', [
                                   { added: ['.appends/labels.yml'], removed: [], modified: [] }
                                 ], false)
  end

  test "should dispatch org-wide-files event when commit contains removed file from .appends directory" do
    Github::DispatchOrgWideFilesRepoUpdateEvent.expects(:defer).with('exercism/website', 'user17')

    Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'website', 'user17', [
                                   { added: [], removed: ['.appends/issues.json'], modified: [] }
                                 ], false)
  end

  test "should dispatch org-wide-files event when commit contains modified file in .appends directory" do
    Github::DispatchOrgWideFilesRepoUpdateEvent.expects(:defer).with('exercism/configlet', 'user17')

    Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'configlet', 'user17', [
                                   { added: [], removed: [], modified: ['.appends/LICENSE.md'] }
                                 ], false)
  end

  test "should not dispatch org-wide-files event when commit does not contain modified file in .appends directory" do
    Github::DispatchOrgWideFilesRepoUpdateEvent.expects(:defer).never

    Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'ruby', 'user17', [
                                   { added: ['README.md'], removed: ['GENERATORS.md'], modified: ['CONTRIBUTING.md'] }
                                 ], false)
  end

  test "should dispatch org-wide-files event when commit contains added org-wide-files-config file" do
    Github::DispatchOrgWideFilesRepoUpdateEvent.expects(:defer).with('exercism/ruby', 'user17')

    Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'ruby', 'user17', [
                                   { added: ['.github/org-wide-files-config.toml'], removed: [], modified: [] }
                                 ], false)
  end

  test "should dispatch org-wide-files event when commit contains removed org-wide-files-config file" do
    Github::DispatchOrgWideFilesRepoUpdateEvent.expects(:defer).with('exercism/website', 'user17')

    Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'website', 'user17', [
                                   { added: [], removed: ['.github/org-wide-files-config.toml'], modified: [] }
                                 ], false)
  end

  test "should dispatch org-wide-files event when commit contains modified org-wide-files-config file" do
    Github::DispatchOrgWideFilesRepoUpdateEvent.expects(:defer).with('exercism/configlet', 'user17')

    Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'configlet', 'user17', [
                                   { added: [], removed: [], modified: ['.github/org-wide-files-config.toml'] }
                                 ], false)
  end

  test "should dispatch org-wide-files event when creating a branch without any org-wide-files related file change" do
    Github::DispatchOrgWideFilesRepoUpdateEvent.expects(:defer).with('exercism/new-repo', 'user17')

    Webhooks::ProcessPushUpdate.('refs/heads/main', 'exercism', 'new-repo', 'user17', [{ added: ['README.md'] }], true)
  end
end
