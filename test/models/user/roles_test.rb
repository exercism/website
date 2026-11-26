require 'test_helper'

class User::RolesTest < ActiveSupport::TestCase
  test "founder?" do
    assert create(:user, roles: [:founder]).founder?
    assert create(:user, roles: %i[founder misc]).founder?
    refute create(:user, roles: [:misc]).founder?
  end

  test "admin?" do
    assert create(:user, roles: [:admin]).admin?
    assert create(:user, roles: %i[admin misc]).admin?
    refute create(:user, roles: [:maintainer_admin]).admin?
    refute create(:user, roles: [:staff]).admin?
    refute create(:user, roles: [:misc]).admin?
  end

  test "maintainer_admin?" do
    assert create(:user, roles: [:maintainer_admin]).maintainer_admin?
    assert create(:user, roles: [:admin]).maintainer_admin?
    refute create(:user, roles: [:maintainer]).maintainer_admin?
    refute create(:user, roles: [:staff]).maintainer_admin?
    refute create(:user, roles: [:misc]).maintainer_admin?
  end

  test "maintainer?" do
    assert create(:user, roles: [:maintainer]).maintainer?
    assert create(:user, roles: %i[maintainer misc]).maintainer?
    assert create(:user, roles: [:maintainer_admin]).maintainer?
    assert create(:user, roles: [:admin]).maintainer?
    refute create(:user, roles: [:staff]).maintainer?
    refute create(:user, roles: [:misc]).maintainer?
  end

  test "staff?" do
    assert create(:user, roles: [:staff]).staff?
    assert create(:user, roles: %i[staff misc]).staff?
    assert create(:user, roles: [:admin]).staff?
    refute create(:user, roles: [:maintainer_admin]).staff?
    refute create(:user, roles: [:misc]).staff?
  end

  test "supermentor?" do
    assert create(:user, roles: [:supermentor]).supermentor?
    assert create(:user, roles: %i[supermentor misc]).supermentor?
    refute create(:user, roles: [:admin]).supermentor?
    refute create(:user, roles: [:staff]).supermentor?
    refute create(:user, roles: [:misc]).supermentor?
  end

  test "moderator?" do
    assert create(:user, roles: [:moderator]).moderator?
    assert create(:user, roles: [:admin]).moderator?
    refute create(:user, roles: [:maintainer_admin]).moderator?
    refute create(:user, roles: [:staff]).moderator?
    refute create(:user, roles: [:misc]).moderator?
  end

  test "mentor?" do
    user = create :user, :not_mentor
    refute user.mentor?

    user.update(became_mentor_at: Time.current)
    assert user.mentor?

    assert create(:user, :not_mentor, roles: [:admin]).mentor?
    assert create(:user, :not_mentor, roles: [:maintainer_admin]).mentor?
    refute create(:user, :not_mentor, roles: [:staff]).mentor?
    refute create(:user, :not_mentor, roles: [:misc]).mentor?
  end
end
