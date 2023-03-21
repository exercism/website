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
end
