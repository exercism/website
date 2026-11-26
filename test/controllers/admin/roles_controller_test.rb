require "test_helper"

class Admin::RolesControllerTest < ActionDispatch::IntegrationTest
  test "index: redirects maintainer admins" do
    sign_in!(create(:user, :maintainer_admin))

    get admin_roles_path

    assert_redirected_to admin_root_path
  end

  test "index: lists everyone with a role" do
    admin = create :user, :admin, handle: "the-admin"
    create :user, roles: [:maintainer], handle: "a-maintainer"
    create :user, roles: [], handle: "no-roles"
    sign_in!(admin)

    get admin_roles_path

    assert_response :success
    assert_select "td a", text: "the-admin"
    assert_select "td a", text: "a-maintainer"
    assert_select "td a", text: "no-roles", count: 0
  end

  test "index: filters by role" do
    admin = create :user, :admin, handle: "the-admin"
    create :user, roles: [:maintainer], handle: "a-maintainer"
    sign_in!(admin)

    get admin_roles_path(role: :maintainer)

    assert_select "td a", text: "a-maintainer"
    assert_select "td a", text: "the-admin", count: 0
  end

  test "create: adds a role and re-identifies the user" do
    sign_in!(create(:user, :admin))
    user = create :user, roles: [], handle: "someone"

    Analytics::IdentifyUser.expects(:defer).with(user)

    post admin_roles_path, params: { handle: "someone", role: "staff" }

    assert_redirected_to admin_roles_path
    assert_includes user.reload.roles, :staff
    assert_equal "someone now has the Staff role.", flash[:notice]
  end

  test "create: keeps the list's filter" do
    sign_in!(create(:user, :admin))
    create :user, roles: [], handle: "someone"

    post admin_roles_path, params: { handle: "someone", role: "maintainer", filter_role: "maintainer", page: "2" }

    assert_redirected_to admin_roles_path(role: "maintainer", page: "2")
  end

  test "create: rejects an unknown role" do
    sign_in!(create(:user, :admin))
    user = create :user, roles: [], handle: "someone"

    post admin_roles_path, params: { handle: "someone", role: "wizard" }

    assert_redirected_to admin_roles_path
    assert_empty user.reload.roles
    assert_equal "Choose a role.", flash[:alert]
  end

  test "create: handles an unknown handle" do
    sign_in!(create(:user, :admin))

    post admin_roles_path, params: { handle: "nobody", role: "staff" }

    assert_redirected_to admin_roles_path
    assert_equal 'Could not find a user with the handle "nobody".', flash[:alert]
  end

  test "create: redirects maintainer admins without changing anything" do
    sign_in!(create(:user, :maintainer_admin))
    user = create :user, roles: [], handle: "someone"

    post admin_roles_path, params: { handle: "someone", role: "admin" }

    assert_redirected_to admin_root_path
    assert_empty user.reload.roles
  end

  test "destroy: removes a role" do
    sign_in!(create(:user, :admin))
    user = create :user, roles: %i[staff maintainer], handle: "someone"

    Analytics::IdentifyUser.expects(:defer).with(user)

    delete admin_role_path("someone"), params: { role: "staff" }

    assert_redirected_to admin_roles_path
    assert_equal [:maintainer], user.reload.roles.to_a
  end

  test "destroy: an admin can't remove their own admin role" do
    admin = create :user, :admin
    sign_in!(admin)

    delete admin_role_path(admin.handle), params: { role: "admin" }

    assert_redirected_to admin_roles_path
    assert admin.reload.admin?
  end
end
