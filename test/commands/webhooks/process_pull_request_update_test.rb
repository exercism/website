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

      assert_no_enqueued_jobs only: ProcessPullRequestUpdateJob do
        Webhooks::ProcessPullRequestUpdate.(**pull_request_update)
      end
    end
  end
end
