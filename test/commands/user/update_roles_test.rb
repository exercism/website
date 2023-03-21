require "test_helper"

class User::UpdateRolesTest < ActiveSupport::TestCase
  test "updates roles" do
    user = create :user, roles: [:staff]
    assert_includes user.roles, :staff
    refute_includes user.roles, :maintainer
    refute_includes user.roles, :supermentor

    User::UpdateRoles.(user, %i[maintainer supermentor])

    refute_includes user.roles, :staff
    assert_includes user.roles, :maintainer
    assert_includes user.roles, :supermentor
  end

  test "updates discourse roles" do
    user = create :user, roles: []

    User::SetDiscordRoles.expects(:call).with(user)

    User::UpdateRoles.(user, [:staff])
  end
end
