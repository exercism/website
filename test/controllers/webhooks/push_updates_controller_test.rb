require_relative './base_test_case'

class Webhooks::PushUpdatesControllerTest < Webhooks::BaseTestCase
  test "create should return 403 when signature is invalid" do
    payload = {
      ref: 'refs/heads/main',
      repository: { name: 'csharp', owner: { login: 'exercism' } },
      commits: [{ added: [], removed: [], modified: ['README.md'] }]
    }

    invalid_headers = headers(payload)
    invalid_headers['HTTP_X_HUB_SIGNATURE_256'] = "invalid_signature"

    post webhooks_push_updates_path, headers: invalid_headers, as: :json, params: payload
    assert_response 403
  end

  test "create should return 200 when signature is valid" do
    payload = {
      ref: 'refs/heads/main',
      repository: { name: 'csharp', owner: { login: 'exercism' } },
      commits: [{ added: [], removed: [], modified: ['README.md'] }]
    }

    post webhooks_push_updates_path, headers: headers(payload), as: :json, params: payload
    assert_response 204
  end

  test "create should process repo update when signature is valid" do
    payload = {
      ref: 'refs/heads/main',
      repository: { name: 'csharp', owner: { login: 'exercism' } },
      commits: [{ added: [], removed: [], modified: ['README.md'] }]
    }
    Webhooks::ProcessPushUpdate.expects(:call).with(
      'refs/heads/main', 'exercism', 'csharp', [
        ActionController::Parameters.new(added: [], removed: [], modified: ['README.md'])
      ]
    )

    post webhooks_push_updates_path, headers: headers(payload), as: :json, params: payload
  end

  test "create should return 204 when ping event is sent" do
    payload = {
      ref: 'refs/heads/main',
      repository: { name: 'csharp', owner: { login: 'exercism' } },
      commits: [{ added: [], removed: [], modified: ['README.md'] }]
    }

    post webhooks_push_updates_path, headers: headers(payload, event: 'ping'), as: :json, params: payload
    assert_response 204
  end
end
