require "test_helper"

class Github::IssueTest < ActiveSupport::TestCase
  test "labels" do
    issue = create :github_issue
    label_1 = create :github_issue_label, issue: issue, label: 'help-wanted'
    label_2 = create :github_issue_label, issue: issue, label: 'good-first-issue'
    label_3 = create :github_issue_label, :random

    assert_includes issue.labels, label_1
    assert_includes issue.labels, label_2
    refute_includes issue.labels, label_3
  end

  test "status_open?" do
    issue = create :github_issue, status: :open

    assert issue.status_open?
    refute issue.status_closed?
  end

  test "status_open!" do
    issue = create :github_issue, status: :closed

    issue.status_open!

    assert issue.status_open?
    refute issue.status_closed?
  end

  test "status_closed?" do
    issue = create :github_issue, status: :closed

    refute issue.status_open?
    assert issue.status_closed?
  end

  test "status_closed!" do
    issue = create :github_issue, status: :open

    issue.status_closed!

    refute issue.status_open?
    assert issue.status_closed?
  end

  test "track for track repo" do
    track = create :track, slug: 'fsharp', repo_url: 'https://github.com/exercism/fsharp'
    issue = create :github_issue, repo: 'exercism/fsharp', track: nil

    assert_equal track, issue.track
  end

  test "track is nil for non-track repo" do
    issue = create :github_issue, repo: 'exercism/configlet'

    assert_nil issue.track
  end

  test "track is already specified" do
    track = create :track, slug: 'csharp'
    issue = create :github_issue, repo: 'exercism/fsharp', track: track

    assert_equal track, issue.track
  end

  test "track is updated when repo updates" do
    track_1 = create :track, slug: 'fsharp', repo_url: 'https://github.com/exercism/fsharp'
    track_2 = create :track, slug: 'ruby', repo_url: 'https://github.com/exercism/ruby'
    issue = create :github_issue, repo: 'exercism/fsharp', track: track_1

    # Sanity check
    assert_equal track_1, issue.track

    issue.update(repo: 'exercism/ruby')

    assert_equal track_2, issue.track
  end
end
