require "test_helper"

class Github::Task::CreateOrUpdateTest < ActiveSupport::TestCase
  test "create task" do
    task = Github::Task::CreateOrUpdate.(
      'https://github.com/exercism/ruby/issues/999',
      title: 'Sync anagram',
      repo: 'exercism/ruby',
      opened_at: Time.parse("2020-10-17T02:39:37Z").utc,
      opened_by_username: "SleeplessByte",
      action: :sync,
      knowledge: :elementary,
      area: :generator,
      size: :small,
      type: :content
    )

    assert_equal 'Sync anagram', task.title
    assert_equal 'exercism/ruby', task.repo
    assert_equal Time.parse("2020-10-17T02:39:37Z").utc, task.opened_at
    assert_equal "SleeplessByte", task.opened_by_username
    assert_equal :sync, task.action
    assert_equal :elementary, task.knowledge
    assert_equal :generator, task.area
    assert_equal :small, task.size
    assert_equal :content, task.type
  end

  test "update task if data has changed" do
    task = create :github_task

    Github::Task::CreateOrUpdate.(
      task.issue_url,
      title: 'Sync anagram',
      repo: 'exercism/ruby',
      opened_at: Time.parse("2020-10-17T02:39:37Z").utc,
      opened_by_username: "SleeplessByte",
      action: :sync,
      knowledge: :elementary,
      area: :generator,
      size: :small,
      type: :content
    )

    task.reload
    assert_equal 'Sync anagram', task.title
    assert_equal 'exercism/ruby', task.repo
    assert_equal Time.parse("2020-10-17T02:39:37Z").utc, task.opened_at
    assert_equal "SleeplessByte", task.opened_by_username
    assert_equal :sync, task.action
    assert_equal :elementary, task.knowledge
    assert_equal :generator, task.area
    assert_equal :small, task.size
    assert_equal :content, task.type
  end

  test "does not update task if data has not changed" do
    freeze_time do
      task = create :github_task
      updated_at_before_call = task.updated_at

      Github::Task::CreateOrUpdate.(
        task.issue_url,
        title: task.title,
        repo: task.repo,
        opened_at: task.opened_at,
        opened_by_username: task.opened_by_username,
        action: task.action,
        knowledge: task.knowledge,
        area: task.area,
        size: task.size,
        type: task.type
      )

      assert_equal updated_at_before_call, task.reload.updated_at
    end
  end

  test "linked to track if issue repo is track repo" do
    track = create :track, slug: 'ruby', repo_url: 'https://github.com/exercism/ruby'

    task = Github::Task::CreateOrUpdate.(
      'https://github.com/exercism/ruby/issues/999',
      title: 'Sync anagram',
      repo: 'exercism/ruby',
      opened_at: Time.parse("2020-10-17T02:39:37Z").utc,
      opened_by_username: "SleeplessByte",
      action: :sync,
      knowledge: :elementary,
      area: :generator,
      size: :small,
      type: :content
    )

    assert_equal track, task.track
  end

  test "linked to track if issue repo is track test runner repo" do
    track = create :track, slug: 'ruby', repo_url: 'https://github.com/exercism/ruby'

    task = Github::Task::CreateOrUpdate.(
      'https://github.com/exercism/ruby/issues/999',
      title: 'Sync anagram',
      repo: 'exercism/ruby-test-runner',
      opened_at: Time.parse("2020-10-17T02:39:37Z").utc,
      opened_by_username: "SleeplessByte",
      action: :sync,
      knowledge: :elementary,
      area: :generator,
      size: :small,
      type: :content
    )

    assert_equal track, task.track
  end

  test "linked to track if issue repo is track analyzer repo" do
    track = create :track, slug: 'ruby', repo_url: 'https://github.com/exercism/ruby'

    task = Github::Task::CreateOrUpdate.(
      'https://github.com/exercism/ruby/issues/999',
      title: 'Sync anagram',
      repo: 'exercism/ruby-analyzer',
      opened_at: Time.parse("2020-10-17T02:39:37Z").utc,
      opened_by_username: "SleeplessByte",
      action: :sync,
      knowledge: :elementary,
      area: :generator,
      size: :small,
      type: :content
    )

    assert_equal track, task.track
  end

  test "linked to track if issue repo is track representer repo" do
    track = create :track, slug: 'ruby', repo_url: 'https://github.com/exercism/ruby'

    task = Github::Task::CreateOrUpdate.(
      'https://github.com/exercism/ruby/issues/999',
      title: 'Sync anagram',
      repo: 'exercism/ruby-representer',
      opened_at: Time.parse("2020-10-17T02:39:37Z").utc,
      opened_by_username: "SleeplessByte",
      action: :sync,
      knowledge: :elementary,
      area: :generator,
      size: :small,
      type: :content
    )

    assert_equal track, task.track
  end

  test "updates track link on update" do
    task = Github::Task::CreateOrUpdate.(
      'https://github.com/exercism/ruby/issues/999',
      title: 'Sync anagram',
      repo: 'exercism/ruby',
      opened_at: Time.parse("2020-10-17T02:39:37Z").utc,
      opened_by_username: "SleeplessByte",
      action: :sync,
      knowledge: :elementary,
      area: :generator,
      size: :small,
      type: :content
    )

    # Sanity check
    assert_nil task.track

    track = create :track, slug: 'ruby', repo_url: 'https://github.com/exercism/ruby'

    task = Github::Task::CreateOrUpdate.(
      'https://github.com/exercism/ruby/issues/999',
      title: 'Sync anagram',
      repo: 'exercism/ruby',
      opened_at: Time.parse("2020-10-17T02:39:37Z").utc,
      opened_by_username: "SleeplessByte",
      action: :sync,
      knowledge: :elementary,
      area: :generator,
      size: :small,
      type: :content
    )

    assert_equal track, task.track
  end

  test "not linked to track if issue repo is not track repo" do
    task = Github::Task::CreateOrUpdate.(
      'https://github.com/exercism/ruby/issues/999',
      title: 'Sync anagram',
      repo: 'exercism/configlet',
      opened_at: Time.parse("2020-10-17T02:39:37Z").utc,
      opened_by_username: "SleeplessByte",
      action: :sync,
      knowledge: :elementary,
      area: :generator,
      size: :small,
      type: :content
    )

    assert_nil task.track
  end
end
