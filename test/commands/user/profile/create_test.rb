require 'test_helper'

class User::Profile::CreateTest < ActiveSupport::TestCase
  test "creates profile" do
    user = create :user, reputation: 10

    profile = User::Profile::Create.(user)

    assert_equal profile.user, user
  end

  test "raises ProfileCriteriaNotFulfilledError when user lacks reputation" do
    user = create :user, reputation: 4 # Just shy of the required 5 reputation

    assert_raises ProfileCriteriaNotFulfilledError do
      User::Profile::Create.(user)
    end
  end
end
