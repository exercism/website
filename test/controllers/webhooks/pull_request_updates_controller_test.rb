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
    assert_response 403
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
        node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
        merged: true
      },
      repository: {
        full_name: 'exercism/fsharp'
      }
    }

    post webhooks_pull_request_updates_path, headers: headers(payload), as: :json, params: payload
    assert_response 204
  end

  test "create should process repo update when signature is valid" do
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
        node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
        merged: true
      },
      repository: {
        full_name: 'exercism/fsharp'
      }
    }
    Webhooks::ProcessPullRequestUpdate.expects(:call).with('opened', 'user22',
      url: 'https://api.github.com/repos/exercism/fsharp/pulls/1347',
      html_url: 'https://github.com/exercism/fsharp/pull/1347',
      labels: %w[bug duplicate],
      state: 'open',
      repo: 'exercism/fsharp',
      pr_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
      pr_number: 4,
      merged: true)

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
        node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
        merged: true
      },
      repository: {
        full_name: 'exercism/fsharp'
      }
    }

    post webhooks_pull_request_updates_path, headers: headers(payload, event: 'ping'), as: :json, params: payload
    assert_response 204
  end
end
