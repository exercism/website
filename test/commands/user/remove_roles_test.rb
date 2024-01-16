require "test_helper"

class User::RemoveRolesTest < ActiveSupport::TestCase
  test "removes roles" do
    user = create :user, roles: %i[maintainer supermentor]
    assert_includes user.roles, :maintainer
    assert_includes user.roles, :supermentor

    User::RemoveRoles.(user, [:supermentor])

    assert_includes user.roles, :maintainer
    refute_includes user.roles, :supermentor
  end

  test "updates discourse roles" do
    user = create :user, roles: []

    User::SetDiscordRoles.expects(:defer).with(user)

    User::RemoveRoles.(user, [:staff])
  end

  test "triggers insiders_status update" do
    user = create :user, roles: []

    User::InsidersStatus::TriggerUpdate.expects(:call).with(user)

    User::RemoveRoles.(user, [:staff])
  end
end
