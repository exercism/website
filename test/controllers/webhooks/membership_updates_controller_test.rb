require_relative './base_test_case'

class Webhooks::MembershipUpdatesControllerTest < Webhooks::BaseTestCase
  # test "create should return 403 when signature is invalid" do
  #   payload = {
  #     action: 'added',
  #     member: {
  #       login: 'member12'
  #     },
  #     team: {
  #       name: 'reviewers'
  #     },
  #     organization: {
  #       login: 'exercism'
  #     }
  #   }

  #   invalid_headers = headers(payload)
  #   invalid_headers['HTTP_X_HUB_SIGNATURE_256'] = "invalid_signature"

  #   post webhooks_membership_updates_path, headers: invalid_headers, as: :json, params: payload
  #   assert_response :forbidden
  # end

  # test "create should return 200 when signature is valid" do
  #   Webhooks::ProcessMembershipUpdate.stubs(:call)

  #   create :user, github_username: 'member12'
  #   create :contributor_team, github_name: 'reviewers'

  #   payload = {
  #     action: 'added',
  #     member: {
  #       login: 'member12'
  #     },
  #     team: {
  #       name: 'reviewers'
  #     },
  #     organization: {
  #       login: 'exercism'
  #     }
  #   }

  #   post webhooks_membership_updates_path, headers: headers(payload), as: :json, params: payload
  #   assert_response :no_content
  # end

  # test "create should process membership update when membership was added and signature is valid" do
  #   create :user, github_username: 'member12'
  #   create :contributor_team, github_name: 'reviewers'

  #   payload = {
  #     action: 'added',
  #     member: {
  #       login: 'member12'
  #     },
  #     team: {
  #       name: 'reviewers'
  #     },
  #     organization: {
  #       login: 'exercism'
  #     }
  #   }
  #   Webhooks::ProcessMembershipUpdate.expects(:call).with('added', 'member12', 'reviewers', 'exercism')

  #   post webhooks_membership_updates_path, headers: headers(payload), as: :json, params: payload
  # end

  # test "create should process membership update when membership was removed and signature is valid" do
  #   create :user, github_username: 'member12'
  #   create :contributor_team, github_name: 'reviewers'

  #   payload = {
  #     action: 'removed',
  #     member: {
  #       login: 'member12'
  #     },
  #     team: {
  #       name: 'reviewers'
  #     },
  #     organization: {
  #       login: 'exercism'
  #     }
  #   }
  #   Webhooks::ProcessMembershipUpdate.expects(:call).with('removed', 'member12', 'reviewers', 'exercism')

  #   post webhooks_membership_updates_path, headers: headers(payload), as: :json, params: payload
  # end

  # test "create should return 204 when ping event is sent" do
  #   payload = {
  #     action: 'added',
  #     member: {
  #       login: 'member12'
  #     },
  #     team: {
  #       name: 'reviewers'
  #     },
  #     organization: {
  #       login: 'exercism'
  #     }
  #   }

  #   post webhooks_membership_updates_path, headers: headers(payload, event: 'ping'), as: :json, params: payload
  #   assert_response :no_content
  # end
end
