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

  test "noop when user already has roles" do
    updated_at = Time.current - 5.days
    user = create :user, roles: %i[staff maintainer supermentor]
    user.update_column(:updated_at, updated_at)

    # Sanity check
    assert_includes user.roles, :staff
    assert_includes user.roles, :maintainer
    assert_includes user.roles, :supermentor

    User::SetDiscordRoles.expects(:defer).never
    User::InsidersStatus::TriggerUpdate.expects(:call).never

    User::AddRoles.(user, %i[staff maintainer])

    assert_includes user.roles, :staff
    assert_includes user.roles, :maintainer
    assert_includes user.roles, :supermentor
    assert_equal updated_at, user.updated_at
  end

  test "updates discourse roles" do
    user = create :user, roles: []

    User::SetDiscordRoles.expects(:defer).with(user)

    User::AddRoles.(user, [:staff])
  end

  test "triggers insiders_status update" do
    user = create :user, roles: []

    User::InsidersStatus::TriggerUpdate.expects(:call).with(user)

    User::AddRoles.(user, [:staff])
  end
end
