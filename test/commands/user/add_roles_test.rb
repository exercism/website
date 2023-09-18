require "test_helper"

class User::AddRolesTest < ActiveSupport::TestCase
  test "adds roles" do
    user = create :user, roles: [:staff]
    assert_includes user.roles, :staff
    refute_includes user.roles, :maintainer
    refute_includes user.roles, :supermentor

    User::AddRoles.(user, %i[maintainer supermentor])

    assert_includes user.roles, :staff
    assert_includes user.roles, :maintainer
    assert_includes user.roles, :supermentor
  end

  test "updates discourse roles" do
    user = create :user, roles: []

    User::SetDiscordRoles.expects(:call).with(user)

    User::AddRoles.(user, [:staff])
  end

  test "triggers insiders_status update" do
    user = create :user, roles: []

    User::InsidersStatus::TriggerUpdate.expects(:call).with(user)

    User::AddRoles.(user, [:staff])
  end
end
