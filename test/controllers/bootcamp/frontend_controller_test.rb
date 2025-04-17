require "test_helper"

class Bootcamp::FrontendControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get bootcamp_frontend_index_url
    assert_response :success
  end
end
