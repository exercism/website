require "test_helper"

class Github::TaskTest < ActiveSupport::TestCase
  test "track set if repo is track repo" do
    track = create :track, slug: 'ruby'
    task = create :github_task, repo: 'exercism/ruby'
    assert_equal track, task.track
  end

  test "track set if repo is test runner repo" do
    track = create :track, slug: 'ruby'
    task = create :github_task, repo: 'exercism/ruby-test-runner'
    assert_equal track, task.track
  end

  test "track set if repo is representer repo" do
    track = create :track, slug: 'ruby'
    task = create :github_task, repo: 'exercism/ruby-representer'
    assert_equal track, task.track
  end

  test "track set if repo is analyzer repo" do
    track = create :track, slug: 'ruby'
    task = create :github_task, repo: 'exercism/ruby-analyzer'
    assert_equal track, task.track
  end

  test "track not set if repo is not a track or track tooling repo" do
    task = create :github_task, track: nil, repo: 'exercism/configlet'
    assert_nil task.track
  end
end
