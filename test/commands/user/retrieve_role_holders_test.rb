require "test_helper"

class User::RetrieveRoleHoldersTest < ActiveSupport::TestCase
  test "returns users with at least one role, by handle" do
    bob = create :user, roles: [:staff], handle: "bob"
    alice = create :user, roles: %i[admin maintainer], handle: "alice"
    create :user, roles: [], handle: "carol"

    assert_equal [alice, bob], User::RetrieveRoleHolders.().to_a
  end

  test "filters by role" do
    create :user, roles: [:staff], handle: "bob"
    alice = create :user, roles: %i[admin maintainer], handle: "alice"

    assert_equal [alice], User::RetrieveRoleHolders.(role: :maintainer).to_a
  end

  test "paginates" do
    users = Array.new(3) { |i| create :user, roles: [:staff], handle: "user-#{i}" }

    assert_equal users[2..], User::RetrieveRoleHolders.(page: 2, per: 2).to_a
  end
end
