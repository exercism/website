require_relative './base_test_case'

class Webhooks::RepoUpdatesControllerTest < Webhooks::BaseTestCase
  test "create should return 403 when signature is invalid" do
    payload = {
      ref: 'refs/heads/master',
      repo: { name: 'csharp' }
    }

    invalid_headers = headers(payload)
    invalid_headers['HTTP_X_HUB_SIGNATURE_256'] = "invalid_signature"

    post webhooks_repo_updates_path, headers: invalid_headers, as: :json, params: payload
    assert_response 403
  end

  test "create should return 200 when signature is valid" do
    payload = {
      ref: 'refs/heads/master',
      repo: { name: 'csharp' }
    }
    create :track, slug: 'csharp'

    post webhooks_repo_updates_path, headers: headers(payload), as: :json, params: payload
    assert_response 200
  end

  test "create should process repo update when signature is valid" do
    payload = {
      ref: 'refs/heads/master',
      repo: { name: 'csharp' }
    }
    create :track, slug: 'csharp'
    Webhooks::ProcessRepoUpdate.expects(:call).with('refs/heads/master', 'csharp')

    post webhooks_repo_updates_path, headers: headers(payload), as: :json, params: payload
  end
end
