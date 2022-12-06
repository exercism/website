require_relative './base_test_case'

class Webhooks::MembershipUpdatesControllerTest < Webhooks::BaseTestCase
  test "create should return 403 when signature is invalid" do
    payload = {
      action: 'added',
      member: {
        id: 12_348_521
      },
      team: {
        name: 'reviewers'
      },
      organization: {
        login: 'exercism'
      }
    }

    invalid_headers = headers(payload)
    invalid_headers['HTTP_X_HUB_SIGNATURE_256'] = "invalid_signature"

    post webhooks_membership_updates_path, headers: invalid_headers, as: :json, params: payload
    assert_response :forbidden
  end

  test "create should return 200 when signature is valid" do
    Webhooks::ProcessMembershipUpdate.stubs(:call)

    payload = {
      action: 'added',
      member: {
        id: 12_348_521
      },
      team: {
        name: 'reviewers'
      },
      organization: {
        login: 'exercism'
      }
    }

    post webhooks_membership_updates_path, headers: headers(payload), as: :json, params: payload
    assert_response :no_content
  end

  test "create should process membership update when membership was added and signature is valid" do
    payload = {
      action: 'added',
      member: {
        id: 12_348_521
      },
      team: {
        name: 'reviewers'
      },
      organization: {
        login: 'exercism'
      }
    }
    Webhooks::ProcessMembershipUpdate.expects(:call).with('added', 12_348_521, 'reviewers', 'exercism')

    post webhooks_membership_updates_path, headers: headers(payload), as: :json, params: payload
  end

  test "create should process membership update when membership was removed and signature is valid" do
    payload = {
      action: 'removed',
      member: {
        id: 12_348_521
      },
      team: {
        name: 'reviewers'
      },
      organization: {
        login: 'exercism'
      }
    }
    Webhooks::ProcessMembershipUpdate.expects(:call).with('removed', 12_348_521, 'reviewers', 'exercism')

    post webhooks_membership_updates_path, headers: headers(payload), as: :json, params: payload
  end

  test "create should return 204 when ping event is sent" do
    payload = {
      action: 'added',
      member: {
        id: 12_348_521
      },
      team: {
        name: 'reviewers'
      },
      organization: {
        login: 'exercism'
      }
    }

    post webhooks_membership_updates_path, headers: headers(payload, event: 'ping'), as: :json, params: payload
    assert_response :no_content
  end
end
