require "test_helper"

class User::DestroyAccountTest < ActiveSupport::TestCase
  test "resets then destroys" do
    user = create :user

    # Create all the things the person might have
    create :user_auth_token, user: user
    create :user_auth_token, user: user

    User::ResetAccount.expects(:call).with(user)

    User::DestroyAccount.(user)

    assert_raises ActiveRecord::RecordNotFound do
      user.reload
    end
  end
end
