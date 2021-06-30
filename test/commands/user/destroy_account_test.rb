require "test_helper"

class User::DestroyAccountTest < ActiveSupport::TestCase
  test "resets then destroys" do
    user = create :user

    User::ResetAccount.expects(:call).with(user)

    User::DestroyAccount.(user)

    assert_raises ActiveRecord::RecordNotFound do
      user.reload
    end
  end
end
