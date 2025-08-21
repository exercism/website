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

  test "noop when user does not have roles" do
    updated_at = Time.current - 5.days
    user = create :user, roles: %i[staff]
    user.update_column(:updated_at, updated_at)

    # Sanity check
    assert_includes user.roles, :staff
    refute_includes user.roles, :maintainer
    refute_includes user.roles, :supermentor

    User::SetDiscordRoles.expects(:defer).never
    User::InsidersStatus::TriggerUpdate.expects(:call).never

    User::RemoveRoles.(user, %i[maintainer supermentor])

    assert_includes user.roles, :staff
    refute_includes user.roles, :maintainer
    refute_includes user.roles, :supermentor
    assert_equal updated_at, user.updated_at
  end

  test "updates discourse roles" do
    user = create :user, roles: [:staff]

    User::SetDiscordRoles.expects(:defer).with(user)

    User::RemoveRoles.(user, [:staff])
  end

  test "triggers insiders_status update" do
    user = create :user, roles: [:staff]

    User::InsidersStatus::TriggerUpdate.expects(:call).with(user)

    User::RemoveRoles.(user, [:staff])
  end
end
