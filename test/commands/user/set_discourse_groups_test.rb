require "test_helper"

class User::SetDiscourseGroupsTest < ActiveSupport::TestCase
  test "nothing happens if the external user isn't found" do
    user = create :user, reputation: User::SetDiscourseGroups::MIN_REP_FOR_TRUST_LEVEL

    stub_request(:get, "https://forum.exercism.org/users/by-external/#{user.id}").to_raise(DiscourseApi::NotFoundError)

    User::SetDiscourseGroups.(user)
  end

  test "set_trust_level works with sufficient rep" do
    user = create :user, reputation: User::SetDiscourseGroups::MIN_REP_FOR_TRUST_LEVEL
    discourse_user_id = 123

    json = { user: { id: discourse_user_id } }.to_json
    stub_request(:get, "https://forum.exercism.org/users/by-external/#{user.id}").to_return(status: 200, body: json, headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength
    stub_request(:put, "https://forum.exercism.org/admin/users/#{discourse_user_id}/trust_level")

    User::SetDiscourseGroups.(user)
  end

  test "set_trust_level is a noop with insufficient rep" do
    user = create :user, reputation: User::SetDiscourseGroups::MIN_REP_FOR_TRUST_LEVEL - 1

    User::SetDiscourseGroups.(user)
  end

  test "pm_enabled works with sufficient rep" do
    user = create :user, reputation: User::SetDiscourseGroups::MIN_REP_FOR_PM_ENABLED
    discourse_user_id = 123
    pm_enabled_group_id = 456

    user_json = { user: { id: discourse_user_id } }.to_json
    group_json = { group: { id: pm_enabled_group_id } }.to_json
    stub_request(:get, "https://forum.exercism.org/users/by-external/#{user.id}").to_return(status: 200, body: user_json, headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength
    stub_request(:get, "https://forum.exercism.org/groups/pm-enabled.json").to_return(status: 200, body: group_json, headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength
    stub_request(:put, "https://forum.exercism.org/admin/groups/#{pm_enabled_group_id}/members.json")

    # Need this for the trust level
    stub_request(:put, "https://forum.exercism.org/admin/users/#{discourse_user_id}/trust_level")

    User::SetDiscourseGroups.(user)
  end

  test "pm_enabled is a noop with insufficient rep" do
    user = create :user, reputation: User::SetDiscourseGroups::MIN_REP_FOR_PM_ENABLED - 1

    # Need this for the trust level
    discourse_user_id = 123
    user_json = { user: { id: discourse_user_id } }.to_json
    stub_request(:get, "https://forum.exercism.org/users/by-external/#{user.id}").to_return(status: 200, body: user_json, headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength
    stub_request(:put, "https://forum.exercism.org/admin/users/#{discourse_user_id}/trust_level")

    User::SetDiscourseGroups.(user)
  end
end
