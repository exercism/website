require "test_helper"

class Webhooks::ProcessRepoUpdateTest < ActiveSupport::TestCase
  test "should sync track when pushing to master branch" do
    track = create :track, slug: 'csharp'
    Git::SyncTrack.expects(:call).with(track)

    Webhooks::ProcessRepoUpdate.('refs/heads/master', 'csharp')
  end

  test "should not sync track when pushing to non-master branch" do
    Git::SyncTrack.expects(:call).never

    Webhooks::ProcessRepoUpdate.('refs/heads/develop', 'csharp')
  end
end
