require_relative './base_test_case'

class API::CommunitySolutionCommentsControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_track_exercise_community_solution_comments_path, args: 3, method: :post
  guard_incorrect_token! :api_track_exercise_community_solution_comments_path, args: 3, method: :get

  ###
  # Index
  ###
  test "index returns comments for request and solution" do
    setup_user
    solution = create :concept_solution, :published, allow_comments: true
    comment = create(:solution_comment, solution:, content_markdown: "Hello", updated_at: Time.utc(2016, 12, 25))

    get api_track_exercise_community_solution_comments_path(
      solution.track, solution.exercise, solution.user.handle
    ), headers: @headers, as: :json

    assert_response :ok
    expected = {
      items: [SerializeSolutionComment.(comment, @current_user)]
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "index should return 404 when solution does not exist" do
    setup_user
    solution = create :practice_solution

    get api_track_exercise_community_solution_comments_path(
      solution.track, solution.exercise, "something random"
    ), headers: @headers, as: :json

    assert_response :not_found
    expected = { error: {
      type: "solution_not_found",
      message: I18n.t('api.errors.solution_not_found')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "index should return 403 when solution is not published" do
    setup_user
    solution = create :practice_solution

    get api_track_exercise_community_solution_comments_path(
      solution.track, solution.exercise, solution.user.handle
    ), headers: @headers, as: :json

    assert_response :forbidden
    expected = { error: {
      type: "solution_comments_not_allowed",
      message: I18n.t('api.errors.solution_comments_not_allowed')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  ###
  # Create
  ###
  test "create should 404 if the solution doesn't exist" do
    setup_user
    solution = create :practice_solution
    post api_track_exercise_community_solution_comments_path(
      solution.track, solution.exercise, "foobar123"
    ), headers: @headers, as: :json
    assert_response :not_found
    expected = { error: {
      type: "solution_not_found",
      message: I18n.t('api.errors.solution_not_found')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should return 403 when solution is not published" do
    setup_user
    solution = create :practice_solution

    post api_track_exercise_community_solution_comments_path(
      solution.track, solution.exercise, solution.user.handle
    ), headers: @headers, as: :json

    assert_response :forbidden
    expected = { error: {
      type: "solution_comments_not_allowed",
      message: I18n.t('api.errors.solution_comments_not_allowed')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should create correctly for user" do
    user = create :user
    solution = create :practice_solution, :published, allow_comments: true
    content_markdown = "foo to the baaar"
    comment = create(:solution_comment, author: user, solution:, content_markdown:)

    # Check we're calling the correet class
    Solution::Comment::Create.expects(:call).with(
      user,
      solution,
      content_markdown
    ).returns(comment)

    setup_user(user)
    post api_track_exercise_community_solution_comments_path(
      solution.track, solution.exercise, solution.user.handle
    ),
      params: { content: content_markdown },
      headers: @headers, as: :json

    assert_response :ok
    comment = solution.comments.last
    assert_equal user, comment.author
    assert_equal content_markdown, comment.content_markdown
    expected = {
      item: SerializeSolutionComment.(comment, user)
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  ###
  # Update
  ###
  test "update: returns 404 error when comment not found" do
    user = create(:user)
    setup_user(user)
    solution = create :practice_solution

    patch api_track_exercise_community_solution_comment_path(
      solution.track, solution.exercise, solution.user.handle, 1
    ), headers: @headers, as: :json

    assert_response :not_found
    expected = { error: {
      type: "solution_comment_not_found",
      message: I18n.t("api.errors.solution_comment_not_found")
    } }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "update: returns 403 error when comment cannot be accessed" do
    user = create(:user)
    setup_user(user)
    solution = create :practice_solution
    comment = create(:solution_comment, solution:)

    patch api_track_exercise_community_solution_comment_path(
      solution.track, solution.exercise, solution.user.handle, comment
    ), headers: @headers, as: :json

    assert_response :forbidden
    expected = { error: {
      type: "solution_comment_not_accessible",
      message: I18n.t("api.errors.solution_comment_not_accessible")
    } }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "returns 400 when validations fail" do
    user = create(:user)
    setup_user(user)
    solution = create :practice_solution
    comment = create(:solution_comment, author: user, solution:)

    patch api_track_exercise_community_solution_comment_path(
      solution.track, solution.exercise, solution.user.handle, comment
    ),
      params: { content: '' },
      headers: @headers,
      as: :json

    assert_response :bad_request
    expected = { error: {
      type: "failed_validations",
      message: I18n.t("api.errors.failed_validations"),
      errors: { content_markdown: ["can't be blank"] }
    } }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "updates a comment" do
    user = create(:user, handle: "user")
    setup_user(user)
    solution = create :practice_solution

    comment = create(:solution_comment,
      solution:,
      author: user,
      content_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25))

    patch api_track_exercise_community_solution_comment_path(
      solution.track, solution.exercise, solution.user.handle, comment
    ),
      params: { content: "content" },
      headers: @headers,
      as: :json

    assert_response :ok

    comment.reload
    expected = { item: SerializeSolutionComment.(comment, user) }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  ###
  # Destroy
  ###
  test "delete: returns 404 error when comment not found" do
    user = create(:user)
    setup_user(user)
    solution = create :practice_solution

    delete api_track_exercise_community_solution_comment_path(
      solution.track, solution.exercise, solution.user.handle, 1
    ), headers: @headers, as: :json

    assert_response :not_found
    expected = { error: {
      type: "solution_comment_not_found",
      message: I18n.t("api.errors.solution_comment_not_found")
    } }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "delete: returns 403 error when comment cannot be accessed" do
    user = create(:user)
    setup_user(user)
    solution = create :practice_solution
    comment = create(:solution_comment, solution:)

    delete api_track_exercise_community_solution_comment_path(
      solution.track, solution.exercise, solution.user.handle, comment
    ), headers: @headers, as: :json

    assert_response :forbidden
    expected = { error: {
      type: "solution_comment_not_accessible",
      message: I18n.t("api.errors.solution_comment_not_accessible")
    } }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "destroys a comment" do
    user = create(:user, handle: "user")
    setup_user(user)
    solution = create :practice_solution
    comment = create(:solution_comment,
      solution:,
      author: user,
      content_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25))

    delete api_track_exercise_community_solution_comment_path(
      solution.track, solution.exercise, solution.user.handle, comment
    ),
      params: { content: "content" },
      headers: @headers,
      as: :json

    assert_response :ok
    expected = { item: SerializeSolutionComment.(comment, user) }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
    refute Solution::Comment.exists?(comment.id)
  end
end
