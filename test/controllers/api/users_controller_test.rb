require_relative './base_test_case'

class API::UsersControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_user_path
  guard_incorrect_token! :api_user_path, method: :put, args: 1

  ###############
  # Get details #
  ###############
  test "show" do
    setup_user
    get api_user_path, headers: @headers, as: :json

    expected = {
      user: {
        handle: @current_user.handle,
        insiders_status: :foobar # TODO!!!!
      }
    }

    assert_response :ok
    assert_equal expected.to_json, response.body
  end

  ##################
  # Update params #
  ##################
  test "update" do
    setup_user
    # TODO: Test the actual avatar gets set - work out how to upload a file.
    params = { user: { something: :else } }
    patch api_user_path, params:, headers: @headers, as: :json

    assert_response :ok
  end
end
