require_relative './base_test_case'

class API::MentorDiscussionsControllerTest < API::BaseTestCase
  ###
  # Create
  ###
  test "create should return 401 with incorrect token" do
    post api_mentor_discussions_path(mentor_request_id: 'xxx'), headers: @headers, as: :json
    assert_response 401
  end

  test "create should 404 if the request doesn't exist" do
    setup_user

    post api_mentor_discussions_path(mentor_request_id: 'xxx'), headers: @headers, as: :json
    assert_response 404
    expected = { error: {
      type: "mentor_request_not_found",
      message: I18n.t('api.errors.mentor_request_not_found')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should 400 if the request is locked" do
    setup_user

    mentor_request = create :solution_mentor_request, :locked
    post api_mentor_discussions_path(mentor_request_id: mentor_request), headers: @headers, as: :json
    assert_response 400
    expected = { error: {
      type: "mentor_request_locked",
      message: I18n.t('api.errors.mentor_request_locked')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should create correctly" do
    user = create :user
    setup_user(user)
    solution = create :concept_solution
    create :iteration, solution: solution, idx: 1
    it_2 = create :iteration, solution: solution, idx: 2
    mentor_request = create :solution_mentor_request, solution: solution

    content = "foo to the baaar"

    post api_mentor_discussions_path,
      params: {
        iteration_idx: 2,
        mentor_request_id: mentor_request.uuid,
        content: content
      },
      headers: @headers, as: :json

    assert_response :success

    discussion = Solution::MentorDiscussion.last
    assert_equal mentor_request, discussion.request
    assert_equal user, discussion.mentor
    assert_equal solution, discussion.solution
    post = discussion.posts.last
    assert_equal user, post.author
    assert_equal content, post.content_markdown
    assert_equal it_2, post.iteration
  end
end
