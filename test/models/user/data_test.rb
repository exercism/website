require 'test_helper'

class User::DataTest < ActiveSupport::TestCase
  test "scope: donor" do
    create :user_data, first_donated_at: nil
    user_2 = create :user_data, first_donated_at: Time.current, show_on_supporters_page: false
    user_3 = create :user_data, first_donated_at: Time.current, show_on_supporters_page: true

    assert_equal [user_2, user_3], User::Data.donors.order(:id)
  end

  test "scope: public_supporter" do
    create :user_data, first_donated_at: nil
    create :user_data, first_donated_at: Time.current, show_on_supporters_page: false
    user_3 = create :user_data, first_donated_at: Time.current, show_on_supporters_page: true

    assert_equal [user_3], User::Data.public_supporter.order(:id)
  end
end
