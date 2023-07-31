require_relative './base_test_case'

class Webhooks::PullRequestUpdatesControllerTest < Webhooks::BaseTestCase
  test "create should return 403 when signature is invalid" do
    payload = {
      action: 'opened',
      pull_request: {
        user: {
          login: 'user22'
        },
        url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
        html_url: 'https://github.com/exercism/fsharp/pull/1347',
        labels: [{ name: "bug" }, { name: "duplicate" }],
        state: 'open',
        number: 4,
        title: "The cat sat on the mat",
        node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
        merged: true
      },
      repository: {
        full_name: 'exercism/fsharp'
      }
    }

    invalid_headers = headers(payload)
    invalid_headers['HTTP_X_HUB_SIGNATURE_256'] = "invalid_signature"

    post webhooks_pull_request_updates_path, headers: invalid_headers, as: :json, params: payload
    assert_response :forbidden
  end

  test "create should return 200 when signature is valid" do
    payload = {
      action: 'opened',
      pull_request: {
        user: {
          login: 'user22'
        },
        url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
        html_url: 'https://github.com/exercism/fsharp/pull/1347',
        labels: [{ name: "bug" }, { name: "duplicate" }],
        state: 'open',
        number: 4,
        title: "The cat sat on the mat",
        node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
        merged: true
      },
      repository: {
        full_name: 'exercism/fsharp'
      }
    }

    post webhooks_pull_request_updates_path, headers: headers(payload), as: :json, params: payload
    assert_response :no_content
  end

  test "create for merged pr should process pr update when signature is valid" do
    payload = {
      action: 'closed',
      pull_request: {
        user: {
          login: 'user22'
        },
        url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
        html_url: 'https://github.com/exercism/fsharp/pull/1347',
        labels: [{ name: "bug" }, { name: "duplicate" }],
        state: 'open',
        number: 4,
        title: "The cat sat on the mat",
        node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
        created_at: "2019-05-15T15:20:33Z",
        closed_at: nil,
        merged_at: "2019-05-28T08:03:01Z",
        merged: true,
        merged_by: {
          login: 'merger68'
        }
      },
      repository: {
        full_name: 'exercism/fsharp'
      }
    }
    Webhooks::ProcessPullRequestUpdate.expects(:call).with(
      action: 'closed',
      author_username: 'user22',
      url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
      html_url: 'https://github.com/exercism/fsharp/pull/1347',
      labels: %w[bug duplicate],
      state: 'open',
      repo: 'exercism/fsharp',
      node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
      number: 4,
      title: "The cat sat on the mat",
      created_at: Time.parse("2019-05-15T15:20:33Z").utc,
      closed_at: nil,
      merged_at: Time.parse("2019-05-28T08:03:01Z").utc,
      merged: true,
      merged_by_username: 'merger68'
    )

    post webhooks_pull_request_updates_path, headers: headers(payload), as: :json, params: payload
  end

  test "create for unmerged pr should process pr update when signature is valid" do
    payload = {
      action: 'opened',
      pull_request: {
        user: {
          login: 'user22'
        },
        url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
        html_url: 'https://github.com/exercism/fsharp/pull/1347',
        labels: [{ name: "bug" }, { name: "duplicate" }],
        state: 'open',
        number: 4,
        title: "The cat sat on the mat",
        node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
        created_at: "2019-05-15T15:20:33Z",
        closed_at: nil,
        merged_at: nil,
        merged: false
      },
      repository: {
        full_name: 'exercism/fsharp'
      }
    }
    Webhooks::ProcessPullRequestUpdate.expects(:call).with(
      action: 'opened',
      author_username: 'user22',
      url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
      html_url: 'https://github.com/exercism/fsharp/pull/1347',
      labels: %w[bug duplicate],
      state: 'open',
      repo: 'exercism/fsharp',
      node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
      number: 4,
      title: "The cat sat on the mat",
      created_at: Time.parse("2019-05-15T15:20:33Z").utc,
      closed_at: nil,
      merged_at: nil,
      merged: false,
      merged_by_username: nil
    )

    post webhooks_pull_request_updates_path, headers: headers(payload), as: :json, params: payload
  end

  test "create for closed pr should process pr update when signature is valid" do
    payload = {
      action: 'closed',
      pull_request: {
        user: {
          login: 'user22'
        },
        url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
        html_url: 'https://github.com/exercism/fsharp/pull/1347',
        labels: [{ name: "bug" }, { name: "duplicate" }],
        state: 'closed',
        number: 4,
        title: "The cat sat on the mat",
        node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
        created_at: "2019-05-15T15:20:33Z",
        closed_at: "2019-05-20T08:44:11Z",
        merged_at: nil,
        merged: false
      },
      repository: {
        full_name: 'exercism/fsharp'
      }
    }
    Webhooks::ProcessPullRequestUpdate.expects(:call).with(
      action: 'closed',
      author_username: 'user22',
      url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
      html_url: 'https://github.com/exercism/fsharp/pull/1347',
      labels: %w[bug duplicate],
      state: 'closed',
      repo: 'exercism/fsharp',
      node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
      number: 4,
      title: "The cat sat on the mat",
      created_at: Time.parse("2019-05-15T15:20:33Z").utc,
      closed_at: Time.parse("2019-05-20T08:44:11Z").utc,
      merged_at: nil,
      merged: false,
      merged_by_username: nil
    )

    post webhooks_pull_request_updates_path, headers: headers(payload), as: :json, params: payload
  end

  test "create should return 204 when ping event is sent" do
    payload = {
      action: 'opened',
      pull_request: {
        user: {
          login: 'user22'
        },
        url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
        html_url: 'https://github.com/exercism/fsharp/pull/1347',
        labels: [{ name: "bug" }, { name: "duplicate" }],
        state: 'open',
        number: 4,
        title: "The cat sat on the mat",
        node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
        merged: true
      },
      repository: {
        full_name: 'exercism/fsharp'
      }
    }

    post webhooks_pull_request_updates_path, headers: headers(payload, event: 'ping'), as: :json, params: payload
    assert_response :no_content
  end
end
