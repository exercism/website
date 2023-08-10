require 'test_helper'

class User::InsidersStatus::UpdateTest < ActiveSupport::TestCase
  test "insider gets update" do
    user = create :user, insiders_status: :active_lifetime

    User::InsidersStatus::Update.expects(:call).with(user)

    User::InsidersStatus::UpdateForPayment.(user)
  end

  test "non-insider gets activate" do
    user = create :user

    User::InsidersStatus::Activate.expects(:call).with(user, recalculate_status: true)

    User::InsidersStatus::UpdateForPayment.(user)
  end
end
