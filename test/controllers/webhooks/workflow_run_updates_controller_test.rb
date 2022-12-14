require_relative './base_test_case'

class Webhooks::PullRequestUpdatesControllerTest < Webhooks::BaseTestCase
  test "create: return 403 when signature is invalid" do
    payload = { action: 'completed' }

    invalid_headers = headers(payload)
    invalid_headers['HTTP_X_HUB_SIGNATURE_256'] = "invalid_signature"

    post webhooks_workflow_run_updates_path, headers: invalid_headers, as: :json, params: payload
    assert_response :forbidden
  end

  test "create: return 200 when signature is valid" do
    payload = { action: 'completed' }

    post webhooks_workflow_run_updates_path, headers: headers(payload), as: :json, params: payload
    assert_response :no_content
  end

  test "create: return 204 when ping event is sent" do
    payload = { action: 'completed' }

    post webhooks_workflow_run_updates_path, headers: headers(payload, event: 'ping'), as: :json, params: payload
    assert_response :no_content
  end

  test "create: processes payload" do
    payload = {
      action: 'completed',
      workflow_run: {
        head_branch: 'main',
        path: '.github/workflows/deploy.yml',
        conclusion: 'failure',
        referenced_workflows: [
          { path: 'deploy.yml' }
        ]
      },
      repository: {
        full_name: 'exercism/fsharp-representer'
      }
    }

    Webhooks::ProcessWorkflowRunUpdate.expects(:call).with(
      action: 'completed',
      repo: 'exercism/fsharp-representer',
      head_branch: 'main',
      path: '.github/workflows/deploy.yml',
      conclusion: 'failure',
      referenced_workflows: ['deploy.yml']
    )

    post webhooks_workflow_run_updates_path, headers: headers(payload), as: :json, params: payload
  end
end
