require_relative '../base_test_case'

class Mentor::RequestsControllerTest < API::BaseTestCase
  ###
  # Lock
  ###
  test "lock should return 401 with incorrect token" do
    patch lock_api_solution_mentor_request_path('xxx', 'xxx'), headers: @headers, as: :json
    assert_response 401
  end

  test "lock should 404 if the request doesn't exist" do
    setup_user
    patch lock_api_solution_mentor_request_path('xxx', 'xxx'), headers: @headers, as: :json
    assert_response 404
  end

  test "locks should succeed" do
    user = create :user
    setup_user(user)
    request = create :solution_mentor_request

    patch lock_api_solution_mentor_request_path('xxx', request.uuid), headers: @headers, as: :json

    assert_response :success

    assert request.reload.locked?
    assert_equal user, request.reload.locked_by
  end
end
