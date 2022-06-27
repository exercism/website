require 'test_helper'

class User::Profile::CreateTest < ActiveSupport::TestCase
  test "creates profile" do
    user = create :user

    profile = User::Profile::Create.(user)

    assert_equal profile.user, user
  end
end
