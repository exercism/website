require "test_helper"

class User::ResetCacheTest < ActiveSupport::TestCase
  test "only affects existing key" do
    user = create :user
    user.data.update(cache: { 'foo': 'bar' })
    assert_equal 'bar', user.data.reload.cache['foo'] # Sanity

    # Create a badge so we get a true value
    create(:user_acquired_badge, user:)
    User::ResetCache.(user, :has_unrevealed_badges?)

    assert user.data.reload.cache['has_unrevealed_badges?']
    assert_equal 'bar', user.data.reload.cache['foo']
  end

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
