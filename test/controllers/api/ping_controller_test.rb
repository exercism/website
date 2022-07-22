require_relative './base_test_case'

class API::PingControllerTest < API::BaseTestCase
  test "should return 200" do
    get api_ping_path, as: :json
    assert_response :ok
  end
end
