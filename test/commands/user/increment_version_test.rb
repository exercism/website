require "test_helper"

class User::IncrementVersionTest < ActiveSupport::TestCase
  test "cleans up attributes" do
    random_user = create :user, version: 5
    user = create :user, version: 5

    User::IncrementVersion.(user)

    assert_equal 5, random_user.version
    assert_equal 6, user.version
  end
end
