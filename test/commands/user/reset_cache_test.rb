require "test_helper"

class User::ResetCacheTest < ActiveSupport::TestCase
  test "sets has_unrevealed_badges correctly" do
    user = create :user
    assert_cache(user, :has_unrevealed_badges?, false)

    user = create :user
    create(:user_acquired_badge, user:)
    assert_cache(user, :has_unrevealed_badges?, true)
  end

  private
  def assert_cache(user, key, expected)
    assert_nil user.data.reload.cache[key.to_s] # Sanity

    User::ResetCache.(user, key)

    assert_equal expected, user.data.reload.cache[key.to_s]
  end
end
