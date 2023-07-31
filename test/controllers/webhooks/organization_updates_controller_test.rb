require_relative './base_test_case'

class Webhooks::OrganizationUpdatesControllerTest < Webhooks::BaseTestCase
  test "create should return 403 when signature is invalid" do
    payload = {
      action: 'member_added',
      membership: {
        user: {
          login: 'member12'
        }
      },
      organization: {
        login: 'exercism'
      }
    }

    invalid_headers = headers(payload)
    invalid_headers['HTTP_X_HUB_SIGNATURE_256'] = "invalid_signature"

    post webhooks_organization_updates_path, headers: invalid_headers, as: :json, params: payload
    assert_response :forbidden
  end

  test "create should return 200 when signature is valid" do
    payload = {
      action: 'member_added',
      membership: {
        user: {
          login: 'member12'
        }
      },
      organization: {
        login: 'exercism'
      }
    }

    post webhooks_organization_updates_path, headers: headers(payload), as: :json, params: payload
    assert_response :no_content
  end

  test "create should process membership update when member was added and signature is valid" do
    payload = {
      action: 'member_added',
      membership: {
        user: {
          login: 'member12'
        }
      },
      organization: {
        login: 'exercism'
      }
    }
    Webhooks::ProcessOrganizationMemberUpdate.expects(:call).with('member_added', 'member12', 'exercism')

    post webhooks_organization_updates_path, headers: headers(payload), as: :json, params: payload
  end

  test "create should process membership update when member was removed and signature is valid" do
    payload = {
      action: 'member_removed',
      membership: {
        user: {
          login: 'member12'
        }
      },
      organization: {
        login: 'exercism'
      }
    }
    Webhooks::ProcessOrganizationMemberUpdate.expects(:call).with('member_removed', 'member12', 'exercism')

    post webhooks_organization_updates_path, headers: headers(payload), as: :json, params: payload
  end

  test "create not should process membership update when member was invited and signature is valid" do
    payload = {
      action: 'member_invited',
      organization: {
        login: 'exercism'
      }
    }
    Webhooks::ProcessOrganizationMemberUpdate.expects(:call).never

    post webhooks_organization_updates_path, headers: headers(payload), as: :json, params: payload
  end

  test "create should return 204 when ping event is sent" do
    payload = {
      action: 'member_added',
      membership: {
        user: {
          login: 'member12'
        }
      },
      organization: {
        login: 'exercism'
      }
    }

    post webhooks_organization_updates_path, headers: headers(payload, event: 'ping'), as: :json, params: payload
    assert_response :no_content
  end
end
