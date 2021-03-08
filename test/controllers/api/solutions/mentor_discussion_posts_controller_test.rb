require_relative '../base_test_case'

class API::Solutions::MentorDiscussionPostsControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_solution_discussion_posts_path, args: 2, method: :post
  guard_incorrect_token! :api_solution_discussion_posts_path, args: 3, method: :get

  ###
  # Index
  ###
  test "index returns posts for discussion and iteration" do
    student = create :user, handle: "student"
    setup_user(student)
    solution = create :concept_solution, user: student
    mentor_request = create :solution_mentor_request,
      solution: solution,
      comment_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25)
    discussion = create :solution_mentor_discussion, solution: solution, request: mentor_request
    iteration = create :iteration, idx: 2, solution: solution
    discussion_post = create(:solution_mentor_discussion_post,
      discussion: discussion,
      iteration: iteration,
      author: student,
      content_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25))

    get api_solution_discussion_posts_path(solution.uuid, discussion), headers: @headers, as: :json

    assert_response 200
    expected = {
      posts: [
        {
          id: "",
          iteration_idx: 2,
          author_id: student.id,
          author_handle: "student",
          author_avatar_url: student.avatar_url,
          by_student: true,
          content_markdown: "Hello",
          content_html: "<p>Hello</p>\n",
          updated_at: Time.utc(2016, 12, 25).iso8601,
          links: {
          }
        },
        {
          id: discussion_post.uuid,
          iteration_idx: 2,
          author_id: student.id,
          author_handle: "student",
          author_avatar_url: student.avatar_url,
          by_student: true,
          content_markdown: "Hello",
          content_html: "<p>Hello</p>\n",
          updated_at: Time.utc(2016, 12, 25).iso8601,
          links: {
            update: Exercism::Routes.api_solution_discussion_post_url(solution.uuid, discussion, discussion_post)
          }
        }
      ]
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "index returns mentor request comment for the last iteration if no posts exist yet" do
    student = create :user, handle: "student"
    setup_user(student)

    mentor = create :user, handle: "mentor"
    solution = create :concept_solution, user: student
    mentor_request = create :solution_mentor_request,
      solution: solution,
      comment_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25)
    discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor, request: mentor_request
    create :iteration, idx: 7, solution: solution

    get api_solution_discussion_posts_path(solution.uuid, discussion), headers: @headers, as: :json

    assert_response 200
    expected = {
      posts: [
        {
          id: "",
          author_id: student.id,
          author_handle: "student",
          author_avatar_url: student.avatar_url,
          by_student: true,
          content_markdown: "Hello",
          content_html: "<p>Hello</p>\n",
          updated_at: Time.utc(2016, 12, 25).iso8601,
          iteration_idx: 7,
          links: {}
        }
      ]
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "index should return 403 when discussion can not be accessed" do
    setup_user
    discussion = create :solution_mentor_discussion
    iteration = create :iteration

    get api_solution_discussion_posts_path(discussion.solution.uuid, discussion, iteration_idx: iteration.idx),
      headers: @headers, as: :json

    assert_response 403
    expected = { error: {
      type: "mentor_discussion_not_accessible",
      message: I18n.t('api.errors.mentor_discussion_not_accessible')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  ###
  # Create
  ###
  test "create should 404 if the discussion doesn't exist" do
    student = create :user
    setup_user(student)

    post api_solution_discussion_posts_path(
      create(:concept_solution, user: student).uuid, 'xxx'
    ), headers: @headers, as: :json

    assert_response 404
    expected = { error: {
      type: "mentor_discussion_not_found",
      message: I18n.t('api.errors.mentor_discussion_not_found')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should return 403 when discussion can not be accessed" do
    setup_user
    discussion = create :solution_mentor_discussion

    post api_solution_discussion_posts_path(discussion.solution.uuid, discussion), headers: @headers, as: :json

    assert_response 403
    expected = { error: {
      type: "mentor_discussion_not_accessible",
      message: I18n.t('api.errors.mentor_discussion_not_accessible')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should create correctly" do
    user = create :user
    setup_user(user)
    solution = create :concept_solution, user: user
    create :iteration, solution: solution, idx: 1
    it_2 = create :iteration, solution: solution, idx: 2
    discussion = create :solution_mentor_discussion, solution: solution

    # Check we're calling the correet class
    User::Notification::Create.expects(:call).with(
      discussion.mentor,
      :student_replied_to_discussion,
      anything
    )

    content = "foo to the baaar"
    post api_solution_discussion_posts_path(solution.uuid, discussion),
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
    expected = {
      post: {
        id: post.uuid,
        author_id: user.id,
        author_handle: user.handle,
        author_avatar_url: user.avatar_url,
        by_student: true,
        content_markdown: content,
        content_html: "<p>#{content}</p>\n",
        updated_at: post.updated_at.iso8601,
        iteration_idx: 2,
        links: {
          update: Exercism::Routes.api_solution_discussion_post_url(solution.uuid, discussion, post)
        }
      }
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  ###
  # Update
  ###
  test "returns 404 error when post not found" do
    student = create(:user)
    setup_user(student)
    solution = create :concept_solution, user: student
    discussion = create :solution_mentor_discussion, solution: solution

    patch api_solution_discussion_post_path(solution.uuid, discussion, 1), headers: @headers, as: :json

    assert_response 404
    expected = { error: {
      type: "mentor_discussion_post_not_found",
      message: I18n.t("api.errors.mentor_discussion_post_not_found")
    } }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "returns 403 error when discussion cannot be accessed" do
    student = create(:user)
    setup_user(student)
    discussion_post = create(:solution_mentor_discussion_post)

    patch api_solution_discussion_post_path(
      discussion_post.discussion.solution.uuid,
      discussion_post.discussion,
      discussion_post
    ), headers: @headers, as: :json

    assert_response 403
    expected = { error: {
      type: "mentor_discussion_not_accessible",
      message: I18n.t("api.errors.mentor_discussion_not_accessible")
    } }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "returns 403 error when post cannot be accessed" do
    student = create(:user)
    setup_user(student)
    solution = create :concept_solution, user: student
    discussion = create :solution_mentor_discussion, solution: solution
    discussion_post = create(:solution_mentor_discussion_post, discussion: discussion, author: create(:user))

    patch api_solution_discussion_post_path(solution.uuid, discussion, discussion_post), headers: @headers, as: :json

    assert_response 403
    expected = { error: {
      type: "mentor_discussion_post_not_accessible",
      message: I18n.t("api.errors.mentor_discussion_post_not_accessible")
    } }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "returns 400 when validations fail" do
    student = create(:user)
    setup_user(student)
    solution = create :concept_solution, user: student
    discussion = create :solution_mentor_discussion, solution: solution
    discussion_post = create(:solution_mentor_discussion_post, author: student, discussion: discussion)

    patch api_solution_discussion_post_path(solution.uuid, discussion, discussion_post),
      params: { content: '' },
      headers: @headers,
      as: :json

    assert_response 400
    expected = { error: {
      type: "failed_validations",
      message: I18n.t("api.errors.failed_validations"),
      errors: { content_markdown: ["can't be blank"] }
    } }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "updates a post" do
    student = create(:user, handle: "student")
    setup_user(student)
    solution = create :concept_solution, user: student
    discussion = create :solution_mentor_discussion, solution: solution

    iteration = create :iteration, idx: 1
    discussion_post = create(:solution_mentor_discussion_post,
      discussion: discussion,
      author: student,
      iteration: iteration,
      content_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25))

    patch api_solution_discussion_post_path(solution.uuid, discussion, discussion_post),
      params: { content: "content" },
      headers: @headers,
      as: :json

    assert_response 200

    discussion_post.reload
    expected = {
      post: {
        id: discussion_post.uuid,
        author_id: student.id,
        author_handle: "student",
        author_avatar_url: student.avatar_url,
        by_student: true,
        content_markdown: "content",
        content_html: "<p>content</p>\n",
        updated_at: discussion_post.updated_at.iso8601,
        iteration_idx: 1,
        links: {
          update: Exercism::Routes.api_solution_discussion_post_url(solution.uuid, discussion, discussion_post)
        }
      }
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end
end
