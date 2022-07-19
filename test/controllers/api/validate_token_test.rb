require_relative './base_test_case'

class API::PingControllerTest < API::BaseTestCase
  test "setup should return 401 with incorrect token" do
    get api_validate_token_path, as: :json
    assert_response :unauthorized
  end

  test "latest should return 200 with correct token" do
    setup_user
    get api_validate_token_path, headers: @headers, as: :json
    assert_response :ok
  end
end
