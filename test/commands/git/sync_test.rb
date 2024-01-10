require "test_helper"

class Git::SyncTest < ActiveSupport::TestCase
  test "filepath_in_diff? returns false if filepath not in diff" do
    track = create :track, synced_to_git_sha: "8995d7fc95ad297d59934a46be263dcad4665924"

    sync = Git::Sync.new(track, track.synced_to_git_sha)

    refute sync.filepath_in_diff?('docs/SNIPPET.txt')
  end

  test "filepath_in_diff? returns true if filepath in diff" do
    track = create :track, synced_to_git_sha: "8995d7fc95ad297d59934a46be263dcad4665924"

    sync = Git::Sync.new(track, track.synced_to_git_sha)

    assert sync.filepath_in_diff?('config.json')
  end

  test "filepath_in_diff? returns true if commit could not be found" do
    track = create :track, synced_to_git_sha: "1111111111222222222233333333334444444444"

    sync = Git::Sync.new(track, track.synced_to_git_sha)

    assert sync.filepath_in_diff?('docs/SNIPPET.txt')
  end

  test "synced_to_head? returns false if not synced to head" do
    repo = Git::Repository.new(repo_url: TestHelpers.git_repo_url("track"))
    previous_head_sha = repo.head_commit.parents.first.oid
    track = create :track, synced_to_git_sha: previous_head_sha

    sync = Git::Sync.new(track, track.synced_to_git_sha)

    refute sync.synced_to_head?
  end

  test "synced_to_head? returns false if commit could not be found" do
    track = create :track, synced_to_git_sha: "1111111111222222222233333333334444444444"

    sync = Git::Sync.new(track, track.synced_to_git_sha)

    refute sync.synced_to_head?
  end

  test "synced_to_head? returns true if synced to head via SHA" do
    repo = Git::Repository.new(repo_url: TestHelpers.git_repo_url("track"))
    head_sha = repo.head_commit.oid
    track = create :track, synced_to_git_sha: head_sha

    sync = Git::Sync.new(track, track.synced_to_git_sha)

    assert sync.synced_to_head?
  end

  test "synced_to_head? returns true if synced to head via HEAD" do
    track = create :track, synced_to_git_sha: "HEAD"

    sync = Git::Sync.new(track, track.synced_to_git_sha)

    assert sync.synced_to_head?
  end
end
