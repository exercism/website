require_relative '../base_test_case'

class API::Solutions::MentorRequestControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_solution_mentor_request_path, args: 2, method: :post
  guard_incorrect_token! :api_solution_mentor_request_path, args: 3, method: :get

  ###
  # Create
  ###
  test "create should 404 if the solution doesn't exist" do
    setup_user
    post api_solution_mentor_request_path(999), headers: @headers, as: :json
    assert_response 404
  end

  test "create should 404 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    post api_solution_mentor_request_path(solution.uuid), headers: @headers, as: :json
    assert_response 403
    expected = { error: {
      type: "solution_not_accessible",
      message: I18n.t('api.errors.solution_not_accessible')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should create correctly" do
    user = create :user
    setup_user(user)
    solution = create :concept_solution, user: user

    comment = "foo to the baaar"
    post api_solution_mentor_request_path(solution.uuid),
      params: { comment: comment },
      headers: @headers, as: :json

    req = Mentor::Request.last
    assert_equal user, req.user
    assert_equal solution, req.solution
    assert_equal comment, req.comment_markdown
    assert_equal "<p>#{comment}</p>\n", req.comment_html

    assert_response :success

    # TODO: Assert correct JSON
    expected = {
      mentor_request: SerializeMentorSessionRequest.(req)
    }.to_json
    assert_equal expected, response.body
  end
end
