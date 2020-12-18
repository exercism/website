require_relative './base_test_case'

class API::MentorDiscussionPostsControllerTest < API::BaseTestCase
  ###
  # Index
  ###
  test "index returns posts for discussion and iteration" do
    mentor = create :user, handle: "author"
    setup_user(mentor)
    discussion = create :solution_mentor_discussion, mentor: mentor
    iteration = create :iteration
    discussion_post = create(:solution_mentor_discussion_post,
      discussion: discussion,
      iteration: iteration,
      author: mentor,
      content_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25))

    get api_mentor_discussion_posts_path(discussion, iteration_idx: iteration.idx), headers: @headers, as: :json

    assert_response 200
    expected = [
      {
        id: discussion_post.uuid,
        author_handle: "author",
        author_avatar_url: mentor.avatar_url,
        by_student: false,
        content_html: "<p>Hello</p>\n",
        updated_at: Time.utc(2016, 12, 25).iso8601
      }
    ]
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  ###
  # Create
  ###
  test "create should return 401 with incorrect token" do
    post api_mentor_discussion_posts_path('xxx'), headers: @headers, as: :json
    assert_response 401
  end

  test "create should 404 if the discussion doesn't exist" do
    setup_user
    post api_mentor_discussion_posts_path('xxx'), headers: @headers, as: :json
    assert_response 404
    expected = { error: {
      type: "mentor_discussion_not_found",
      message: I18n.t('api.errors.mentor_discussion_not_found')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should 403 unless user is mentor or student" do
    user = create :user
    setup_user(user)

    solution = create :concept_solution
    create :iteration, solution: solution, idx: 1
    discussion = create :solution_mentor_discussion, solution: solution

    post api_mentor_discussion_posts_path(discussion),
      params: {
        iteration_idx: 1,
        content: "foo to the baaar"
      },
      headers: @headers, as: :json

    assert_response 403
    expected = { error: {
      type: "permission_denied",
      message: I18n.t('api.errors.permission_denied')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual

    assert_equal 0, discussion.posts.size
  end

  test "create should create correctly for mentor" do
    user = create :user
    setup_user(user)
    solution = create :concept_solution
    create :iteration, solution: solution, idx: 1
    it_2 = create :iteration, solution: solution, idx: 2
    discussion = create :solution_mentor_discussion,
      solution: solution,
      mentor: user

    # Check we're calling the correet class
    Notification::Create.expects(:call).with(
      solution.user,
      :mentor_replied_to_discussion,
      anything
    )

    content = "foo to the baaar"

    post api_mentor_discussion_posts_path(discussion),
      params: {
        iteration_idx: 2,
        content: content
      },
      headers: @headers, as: :json

    assert_response :success

    post = discussion.posts.last
    assert_equal user, post.author
    assert_equal content, post.content_markdown
    assert_equal it_2, post.iteration
  end

  test "create should create correctly for student" do
    user = create :user
    setup_user(user)
    solution = create :concept_solution, user: user
    create :iteration, solution: solution, idx: 1
    it_2 = create :iteration, solution: solution, idx: 2
    discussion = create :solution_mentor_discussion, solution: solution

    # Check we're calling the correet class
    Notification::Create.expects(:call).with(
      discussion.mentor,
      :student_replied_to_discussion,
      anything
    )

    content = "foo to the baaar"
    post api_mentor_discussion_posts_path(discussion),
      params: {
        iteration_idx: 2,
        content: content
      },
      headers: @headers, as: :json

    assert_response :success

    post = discussion.posts.last
    assert_equal user, post.author
    assert_equal content, post.content_markdown
    assert_equal it_2, post.iteration
  end
end
