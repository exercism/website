require_relative './base_test_case'

class Webhooks::IssueUpdatesControllerTest < Webhooks::BaseTestCase
  test "create should return 403 when signature is invalid" do
    payload = {
      action: 'opened',
      issue: {
        user: {
          login: 'user22'
        },
        node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
        html_url: 'https://github.com/exercism/fsharp/issues/4',
        number: 4,
        title: 'Fix lint errors',
        state: 'open',
        created_at: "2021-05-21T10:42:26Z",
        labels: [
          { name: 'bug' },
          { name: 'duplicate' }
        ]
      },
      repository: {
        full_name: 'exercism/fsharp'
      }
    }

    invalid_headers = headers(payload)
    invalid_headers['HTTP_X_HUB_SIGNATURE_256'] = "invalid_signature"

    post webhooks_issue_updates_path, headers: invalid_headers, as: :json, params: payload
    assert_response :forbidden
  end

  test "create should return 200 when signature is valid" do
    payload = {
      action: 'opened',
      issue: {
        user: {
          login: 'user22'
        },
        node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
        html_url: 'https://github.com/exercism/fsharp/issues/4',
        number: 4,
        title: 'Fix lint errors',
        state: 'open',
        created_at: "2021-05-21T10:42:26Z",
        labels: [
          { name: 'bug' },
          { name: 'duplicate' }
        ]
      },
      repository: {
        full_name: 'exercism/fsharp'
      }
    }

    post webhooks_issue_updates_path, headers: headers(payload), as: :json, params: payload
    assert_response :no_content
  end

  test "create should return 204 when ping event is sent" do
    payload = {
      action: 'opened',
      issue: {
        user: {
          login: 'user22'
        },
        node_id: 'MDExOlB1bGxSZXF1ZXN0NTgzMTI1NTaQ',
        html_url: 'https://github.com/exercism/fsharp/issues/4',
        number: 4,
        title: 'Fix lint errors',
        state: 'open',
        created_at: "2021-05-21T10:42:26Z",
        labels: [
          { name: 'bug' },
          { name: 'duplicate' }
        ]
      },
      repository: {
        full_name: 'exercism/fsharp'
      }
    }

    post webhooks_issue_updates_path, headers: headers(payload, event: 'ping'), as: :json, params: payload
    assert_response :no_content
  end
end
