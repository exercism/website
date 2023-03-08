require "test_helper"

class Admin::DonorsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_donors_index_url
    assert_response :success
  end

  test "should get new" do
    get admin_donors_new_url
    assert_response :success
  end
end
