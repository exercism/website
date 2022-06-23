require "test_helper"

class Webhooks::ProcessPullRequestUpdateTest < ActiveSupport::TestCase
  %w[closed edited opened reopened labeled unlabeled].each do |action|
    test "should not process pull request when action is #{action}" do
      pull_request_update = {
        action:,
        login: 'user22',
        url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
        html_url: 'https://github.com/exercism/fsharp/pull/1347',
        labels: %w[bug duplicate],
        state: 'open',
        repo: 'exercism/fsharp',
        number: 4
      }

      assert_enqueued_jobs 1, only: ProcessPullRequestUpdateJob do
        Webhooks::ProcessPullRequestUpdate.(**pull_request_update)
      end
    end
  end

  %w[assigned auto_merge_disabled auto_merge_enabled converted_to_draft
     locked ready_for_review review_request_removed review_requested
     synchronize unassigned unlocked].each do |action|
    test "should not process pull request when action is #{action}" do
      pull_request_update = {
        action:,
        login: 'user22',
        url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
        html_url: 'https://github.com/exercism/fsharp/pull/1347',
        labels: %w[bug duplicate],
        state: 'open',
        repo: 'exercism/fsharp',
        number: 4
      }

      assert_enqueued_jobs 0, only: ProcessPullRequestUpdateJob do
        Webhooks::ProcessPullRequestUpdate.(**pull_request_update)
      end
    end
  end

  test "adds open metric when action is opened for track repo" do
    track = create :track, slug: 'fsharp', repo_url: 'https://github.com/exercism/fsharp'
    author = create :user, github_username: 'iHiD'

    params = {
      action: 'opened',
      login: 'user22',
      url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
      html_url: 'https://github.com/exercism/fsharp/pull/1347',
      labels: %w[bug duplicate],
      repo: 'exercism/fsharp',
      number: 4,
      author_username: author.github_username,
      created_at: Time.parse("2020-10-17T02:39:37Z").utc
    }

    perform_enqueued_jobs do
      Webhooks::ProcessPullRequestUpdate.(**params)
    end

    assert_equal 1, Metric.where(metric_action: :open_pull_request).count
    metric = Metric.where(metric_action: :open_pull_request).last
    assert_equal params[:created_at].to_time, metric.created_at
    assert_equal :open_pull_request, metric.metric_action
    assert_equal track, metric.track
    assert_equal author, metric.user
  end

  test "adds open metric when action is opened for non-track repo" do
    author = create :user, github_username: 'iHiD'

    params = {
      action: 'opened',
      login: 'user22',
      url: 'https://api.github.com/repos/exercism/configlet/pulls/1347',
      html_url: 'https://github.com/exercism/configlet/pull/1347',
      labels: %w[bug duplicate],
      repo: 'exercism/configlet',
      number: 4,
      author_username: author.github_username,
      created_at: Time.parse("2020-10-17T02:39:37Z").utc
    }

    perform_enqueued_jobs do
      Webhooks::ProcessPullRequestUpdate.(**params)
    end

    assert_equal 1, Metric.where(metric_action: :open_pull_request).count
    metric = Metric.where(metric_action: :open_pull_request).last
    assert_equal params[:created_at].to_time, metric.created_at
    assert_equal :open_pull_request, metric.metric_action
    assert_nil metric.track
    assert_equal author, metric.user
  end

  test "adds open metric when action is opened and author is unknown" do
    track = create :track, slug: 'fsharp', repo_url: 'https://github.com/exercism/fsharp'

    params = {
      action: 'opened',
      login: 'user22',
      url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
      html_url: 'https://github.com/exercism/fsharp/pull/1347',
      labels: %w[bug duplicate],
      repo: 'exercism/fsharp',
      number: 4,
      author_username: 'unknown',
      created_at: Time.parse("2020-10-17T02:39:37Z").utc
    }

    perform_enqueued_jobs do
      Webhooks::ProcessPullRequestUpdate.(**params)
    end

    assert_equal 1, Metric.where(metric_action: :open_pull_request).count
    metric = Metric.where(metric_action: :open_pull_request).last
    assert_equal params[:created_at].to_time, metric.created_at
    assert_equal :open_pull_request, metric.metric_action
    assert_equal track, metric.track
    assert_nil metric.user
  end

  %i[assigned auto_merge_disabled auto_merge_enabled closed converted_to_draft edited
     labeled locked ready_for_review reopened review_request_removed review_requested
     synchronize unassigned unlabeled unlocked].each do |action|
    test "does not add open metric when pr action is #{action}" do
      params = {
        action:,
        login: 'user22',
        url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
        html_url: 'https://github.com/exercism/fsharp/pull/1347',
        labels: %w[bug duplicate],
        repo: 'exercism/fsharp',
        number: 4,
        author_username: 'unknown',
        created_at: Time.parse("2020-10-17T02:39:37Z").utc
      }

      perform_enqueued_jobs do
        Webhooks::ProcessPullRequestUpdate.(**params)
      end

      refute Metric.where(metric_action: :open_pull_request).exists?
    end
  end

  test "adds merge metric when action is closed and merged for track repo" do
    track = create :track, slug: 'fsharp', repo_url: 'https://github.com/exercism/fsharp'
    merged_by = create :user, github_username: 'iHiD'

    params = {
      action: 'closed',
      login: 'user22',
      url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
      html_url: 'https://github.com/exercism/fsharp/pull/1347',
      labels: %w[bug duplicate],
      repo: 'exercism/fsharp',
      number: 4,
      merged: true,
      merged_by_username: merged_by.github_username,
      merged_at: Time.parse("2020-10-17T02:39:37Z").utc
    }

    perform_enqueued_jobs do
      Webhooks::ProcessPullRequestUpdate.(**params)
    end

    assert_equal 1, Metric.where(metric_action: :merge_pull_request).count
    metric = Metric.where(metric_action: :merge_pull_request).last
    assert_equal params[:merged_at].to_time, metric.created_at
    assert_equal :merge_pull_request, metric.metric_action
    assert_equal track, metric.track
    assert_equal merged_by, metric.user
  end

  test "adds merge metric when action is closed and merged for non-track repo" do
    merged_by = create :user, github_username: 'iHiD'

    params = {
      action: 'closed',
      login: 'user22',
      url: 'https://api.github.com/repos/exercism/configlet/pulls/1347',
      html_url: 'https://github.com/exercism/configlet/pull/1347',
      labels: %w[bug duplicate],
      repo: 'exercism/configlet',
      number: 4,
      merged: true,
      merged_by_username: merged_by.github_username,
      merged_at: Time.parse("2020-10-17T02:39:37Z").utc
    }

    perform_enqueued_jobs do
      Webhooks::ProcessPullRequestUpdate.(**params)
    end

    assert_equal 1, Metric.where(metric_action: :merge_pull_request).count
    metric = Metric.where(metric_action: :merge_pull_request).last
    assert_equal params[:merged_at].to_time, metric.created_at
    assert_equal :merge_pull_request, metric.metric_action
    assert_nil metric.track
    assert_equal merged_by, metric.user
  end

  test "adds merge metric when action is closed and merged with unknown author" do
    track = create :track, slug: 'fsharp', repo_url: 'https://github.com/exercism/fsharp'

    params = {
      action: 'closed',
      login: 'user22',
      url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
      html_url: 'https://github.com/exercism/fsharp/pull/1347',
      labels: %w[bug duplicate],
      repo: 'exercism/fsharp',
      number: 4,
      merged: true,
      author_username: 'unknown',
      merged_at: Time.parse("2020-10-17T02:39:37Z").utc
    }

    perform_enqueued_jobs do
      Webhooks::ProcessPullRequestUpdate.(**params)
    end

    assert_equal 1, Metric.where(metric_action: :merge_pull_request).count
    metric = Metric.where(metric_action: :merge_pull_request).last
    assert_equal params[:merged_at].to_time, metric.created_at
    assert_equal :merge_pull_request, metric.metric_action
    assert_equal track, metric.track
    assert_nil metric.user
  end

  test "does not add closed metric when pr action is closed but not merged" do
    params = {
      action: 'closed',
      login: 'user22',
      url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
      html_url: 'https://github.com/exercism/fsharp/pull/1347',
      labels: %w[bug duplicate],
      repo: 'exercism/fsharp',
      number: 4,
      merged: false,
      created_at: Time.parse("2020-10-17T02:39:37Z").utc
    }

    perform_enqueued_jobs do
      Webhooks::ProcessPullRequestUpdate.(**params)
    end

    refute Metric.where(metric_action: :merge_pull_request).exists?
  end

  %i[assigned auto_merge_disabled auto_merge_enabled converted_to_draft edited labeled
     locked opened ready_for_review reopened review_request_removed review_requested
     synchronize unassigned unlabeled unlocked].each do |action|
    test "does not add closed metric when pr action is #{action}" do
      params = {
        action:,
        login: 'user22',
        url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
        html_url: 'https://github.com/exercism/fsharp/pull/1347',
        labels: %w[bug duplicate],
        repo: 'exercism/fsharp',
        number: 4,
        author_username: 'unknown',
        created_at: Time.parse("2020-10-17T02:39:37Z").utc
      }

      perform_enqueued_jobs do
        Webhooks::ProcessPullRequestUpdate.(**params)
      end

      refute Metric.where(metric_action: :merge_pull_request).exists?
    end
  end
end
