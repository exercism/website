require "test_helper"

class User::SetDiscourseGroupsTest < ActiveSupport::TestCase
  test "nothing happens if the external user isn't found" do
    user = create :user, reputation: User::SetDiscourseGroups::MIN_REP_FOR_TRUST_LEVEL

    stub_request(:get, "https://forum.exercism.org/users/by-external/#{user.id}").to_raise(DiscourseApi::NotFoundError)

    User::SetDiscourseGroups.(user)
  end

  test "set_trust_level works with sufficient rep" do
    user = create :user, reputation: User::SetDiscourseGroups::MIN_REP_FOR_TRUST_LEVEL

    stub_user_requests(user)
    stub_insider_group_requests
    stub_request(:put, "https://forum.exercism.org/admin/users/#{DISCOURSE_USER_ID}/trust_level")

    User::SetDiscourseGroups.(user)
  end

  test "set_trust_level is a noop with insufficient rep" do
    user = create :user, reputation: User::SetDiscourseGroups::MIN_REP_FOR_TRUST_LEVEL - 1
    stub_user_requests(user)
    stub_insider_group_requests

    User::SetDiscourseGroups.(user)
  end

  test "pm_enabled works with sufficient rep" do
    user = create :user, reputation: User::SetDiscourseGroups::MIN_REP_FOR_PM_ENABLED

    stub_user_requests(user)
    stub_insider_group_requests
    group_json = { group: { id: PM_ENABLED_GROUP_ID } }.to_json
    stub_request(:get, "https://forum.exercism.org/groups/#{PM_ENABLED_GROUP_NAME}.json").to_return(status: 200, body: group_json, headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength
    stub_request(:put, "https://forum.exercism.org/admin/groups/#{PM_ENABLED_GROUP_ID}/members.json")

    # Need this for the trust level
    stub_request(:put, "https://forum.exercism.org/admin/users/#{DISCOURSE_USER_ID}/trust_level")

    User::SetDiscourseGroups.(user)
  end

  test "pm_enabled gracefully handles user already being in group" do
    user = create :user, reputation: User::SetDiscourseGroups::MIN_REP_FOR_PM_ENABLED

    stub_insider_group_requests
    user_json = { user: { id: DISCOURSE_USER_ID, groups: { id: PM_ENABLED_GROUP_ID } } }.to_json
    group_json = { group: { id: PM_ENABLED_GROUP_ID } }.to_json
    stub_request(:get, "https://forum.exercism.org/users/by-external/#{user.id}").to_return(status: 200, body: user_json, headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength
    stub_request(:get, "https://forum.exercism.org/groups/#{PM_ENABLED_GROUP_NAME}.json").to_return(status: 200, body: group_json, headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength
    stub_request(:put, "https://forum.exercism.org/admin/groups/#{PM_ENABLED_GROUP_ID}/members.json").to_return(status: 422, body: '{"user_count": 1, "errors": ["already a member"]}', headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength

    # Need this for the trust level
    stub_request(:put, "https://forum.exercism.org/admin/users/#{DISCOURSE_USER_ID}/trust_level")

    User::SetDiscourseGroups.(user)
  end

  test "pm_enabled is a noop with insufficient rep" do
    user = create :user, reputation: User::SetDiscourseGroups::MIN_REP_FOR_PM_ENABLED - 1

    # Need this for the trust level
    stub_insider_group_requests
    user_json = { user: { id: DISCOURSE_USER_ID } }.to_json
    stub_request(:get, "https://forum.exercism.org/users/by-external/#{user.id}").to_return(status: 200, body: user_json, headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength
    stub_request(:put, "https://forum.exercism.org/admin/users/#{DISCOURSE_USER_ID}/trust_level")

    User::SetDiscourseGroups.(user)
  end

  test "insider user is added to insiders group" do
    user = create :user, :insider

    stub_insider_group_requests
    user_json = { user: { id: DISCOURSE_USER_ID } }.to_json
    group_json = { group: { id: INSIDERS_GROUP_ID } }.to_json
    stub_request(:get, "https://forum.exercism.org/users/by-external/#{user.id}").to_return(status: 200, body: user_json, headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength
    stub_request(:get, "https://forum.exercism.org/groups/#{PM_ENABLED_GROUP_NAME}.json").to_return(status: 200, body: group_json, headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength
    stub_request(:put, "https://forum.exercism.org/admin/groups/#{INSIDERS_GROUP_ID}/members.json")

    User::SetDiscourseGroups.(user)
  end

  test "gracefully handles insider user already added to insiders group" do
    user = create :user, :insider

    stub_insider_group_requests
    user_json = { user: { id: DISCOURSE_USER_ID, groups: { id: INSIDERS_GROUP_ID } } }.to_json
    group_json = { group: { id: INSIDERS_GROUP_ID } }.to_json
    stub_request(:get, "https://forum.exercism.org/users/by-external/#{user.id}").to_return(status: 200, body: user_json, headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength
    stub_request(:get, "https://forum.exercism.org/groups/#{PM_ENABLED_GROUP_NAME}.json").to_return(status: 200, body: group_json, headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength
    stub_request(:put, "https://forum.exercism.org/admin/groups/#{INSIDERS_GROUP_ID}/members.json").to_return(status: 422, body: '{"user_count": 1, "errors": ["already a member"]}', headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength

    # Need this for the trust level
    stub_request(:put, "https://forum.exercism.org/admin/users/#{DISCOURSE_USER_ID}/trust_level")

    User::SetDiscourseGroups.(user)
  end

  test "non-insider user is removed from insiders group" do
    user = create :user, insiders_status: :ineligible

    stub_insider_group_requests
    user_json = { user: { id: DISCOURSE_USER_ID } }.to_json
    group_json = { group: { id: INSIDERS_GROUP_ID } }.to_json
    stub_request(:get, "https://forum.exercism.org/users/by-external/#{user.id}").to_return(status: 200, body: user_json, headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength
    stub_request(:get, "https://forum.exercism.org/groups/#{PM_ENABLED_GROUP_NAME}.json").to_return(status: 200, body: group_json, headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength
    stub_request(:put, "https://forum.exercism.org/admin/groups/#{INSIDERS_GROUP_ID}/members.json")

    # Need this for the trust level
    stub_request(:put, "https://forum.exercism.org/admin/users/#{DISCOURSE_USER_ID}/trust_level")

    User::SetDiscourseGroups.(user)
  end

  test "gracefully handles non-insider user not in insiders group" do
    user = create :user, insiders_status: :ineligible

    stub_insider_group_requests
    user_json = { user: { id: DISCOURSE_USER_ID, groups: { id: INSIDERS_GROUP_ID } } }.to_json
    group_json = { group: { id: INSIDERS_GROUP_ID } }.to_json
    stub_request(:get, "https://forum.exercism.org/users/by-external/#{user.id}").to_return(status: 200, body: user_json, headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength
    stub_request(:get, "https://forum.exercism.org/groups/#{PM_ENABLED_GROUP_NAME}.json").to_return(status: 200, body: group_json, headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength
    stub_request(:put, "https://forum.exercism.org/admin/groups/#{INSIDERS_GROUP_ID}/members.json").to_return(status: 422, body: '{"user_count": 1, "errors": ["already a member"]}', headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength

    # Need this for the trust level
    stub_request(:put, "https://forum.exercism.org/admin/users/#{DISCOURSE_USER_ID}/trust_level")

    User::SetDiscourseGroups.(user)
  end

  def stub_user_requests(user)
    json = { user: { id: DISCOURSE_USER_ID } }.to_json
    stub_request(:get, "https://forum.exercism.org/users/by-external/#{user.id}").to_return(status: 200, body: json, headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength
  end

  def stub_insider_group_requests
    group_json = { group: { id: INSIDERS_GROUP_ID } }.to_json
    stub_request(:get, "https://forum.exercism.org/groups/#{INSIDERS_GROUP_NAME}.json").to_return(status: 200, body: group_json, headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength
    stub_request(:put, "https://forum.exercism.org/admin/groups/#{INSIDERS_GROUP_ID}/members.json")
    stub_request(:delete, "https://forum.exercism.org/admin/groups/#{INSIDERS_GROUP_ID}/members.json?user_ids=#{DISCOURSE_USER_ID}")
  end

  DISCOURSE_USER_ID = 123

  PM_ENABLED_GROUP_ID = 456
  PM_ENABLED_GROUP_NAME = "pm-enabled".freeze

  INSIDERS_GROUP_ID = 789
  INSIDERS_GROUP_NAME = "insiders".freeze
end
