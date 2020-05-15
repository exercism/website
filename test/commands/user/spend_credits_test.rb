require "test_helper"

class User::SpendCreditsTest < ActiveSupport::TestCase
  test "spends the credits" do
    user = create :user, credits: 5
    User::SpendCredits.(user, 3)
    assert_equal 2, user.reload.credits
  end

  test "raises without enough credits" do
    user = create :user, credits: 1
    assert_raises NotEnoughCreditsError do
      User::SpendCredits.(user, 3)
    end
  end
end
