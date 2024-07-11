require "test_helper"

class User::BecomeMaintainerTest < ActiveSupport::TestCase
  test "creates correctly" do
    user = create :user

    # Sanity check
    refute user.maintainer?

    User::BecomeMaintainer.(user)
    assert user.maintainer?
  end

  test "skips if user is already a maintainer" do
    old_time = Time.current - 1.week
    user = create :user, :maintainer
    user.update_column(:updated_at, old_time)

    # Sanity check
    assert user.maintainer?

    User::BecomeMaintainer.(user)
    assert user.maintainer?
    assert_equal old_time, user.reload.updated_at
  end
end
