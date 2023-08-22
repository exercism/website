require_relative '../base_test_case'

class API::Solutions::MentorDiscussionPostsControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_solution_discussion_posts_path, args: 2, method: :post
  guard_incorrect_token! :api_solution_discussion_posts_path, args: 3, method: :get

  ###
  # Index
  ###
  test "index returns posts for request and discussion" do
    student = create :user, handle: "student"
    setup_user(student)
    solution = create :concept_solution, user: student
    mentor_request = create :mentor_request,
      solution:,
      comment_markdown: "Request comment",
      created_at: Time.utc(2016, 12, 25)
    discussion = create :mentor_discussion, solution:, request: mentor_request
    iteration = create(:iteration, idx: 2, solution:)
    discussion_post = create(:mentor_discussion_post,
      discussion:,
      iteration:,
      author: student,
      content_markdown: "Discussion post",
      updated_at: Time.utc(2016, 12, 25))

    get api_solution_discussion_posts_path(solution.uuid, discussion), headers: @headers, as: :json

    assert_response :ok
    expected = {
      items: [
        {
          uuid: "request-comment",
          iteration_idx: 2,
          author_handle: "student",
          author_flair: student.flair,
          author_avatar_url: student.avatar_url,
          by_student: true,
          content_markdown: "Request comment",
          content_html: "<p>Request comment</p>\n",
          updated_at: Time.utc(2016, 12, 25).iso8601,
          links: {
            edit: Exercism::Routes.api_solution_mentor_request_url(solution.uuid, discussion.request.uuid)
          }
        },
        {
          uuid: discussion_post.uuid,
          iteration_idx: 2,
          author_handle: "student",
          author_flair: student.flair,
          author_avatar_url: student.avatar_url,
          by_student: true,
          content_markdown: "Discussion post",
          content_html: "<p>Discussion post</p>\n",
          updated_at: Time.utc(2016, 12, 25).iso8601,
          links: {
            edit: Exercism::Routes.api_solution_discussion_post_url(solution.uuid, discussion, discussion_post),
            delete: Exercism::Routes.api_solution_discussion_post_url(solution.uuid, discussion, discussion_post)
          }
        }
      ]
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "index returns just mentor request comment" do
    student = create :user, handle: "student"
    setup_user(student)

    mentor = create :user, handle: "mentor"
    solution = create :concept_solution, user: student
    mentor_request = create :mentor_request,
      solution:,
      comment_markdown: "Hello",
      created_at: Time.utc(2016, 12, 25)
    discussion = create :mentor_discussion, solution:, mentor:, request: mentor_request
    create(:iteration, idx: 7, solution:)

    get api_solution_discussion_posts_path(solution.uuid, discussion), headers: @headers, as: :json

    assert_response :ok
    expected = {
      items: [
        {
          uuid: "request-comment",
          author_handle: "student",
          author_flair: student.flair,
          author_avatar_url: student.avatar_url,
          by_student: true,
          content_markdown: "Hello",
          content_html: "<p>Hello</p>\n",
          updated_at: Time.utc(2016, 12, 25).iso8601,
          iteration_idx: 7,
          links: {
            edit: Exercism::Routes.api_solution_mentor_request_url(solution.uuid, discussion.request.uuid)
          }
        }
      ]
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "index should return 403 when discussion can not be accessed" do
    setup_user
    discussion = create :mentor_discussion
    iteration = create :iteration

    get api_solution_discussion_posts_path(discussion.solution.uuid, discussion, iteration_idx: iteration.idx),
      headers: @headers, as: :json

    assert_response :forbidden
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

    assert_response :not_found
    expected = { error: {
      type: "mentor_discussion_not_found",
      message: I18n.t('api.errors.mentor_discussion_not_found')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should return 403 when discussion can not be accessed" do
    setup_user
    discussion = create :mentor_discussion

    post api_solution_discussion_posts_path(discussion.solution.uuid, discussion), headers: @headers, as: :json

    assert_response :forbidden
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
    solution = create(:concept_solution, user:)
    create :iteration, solution:, idx: 1
    it_2 = create :iteration, solution:, idx: 2
    discussion = create(:mentor_discussion, solution:)

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
        content:
      },
      headers: @headers, as: :json

    assert_response :ok

    post = discussion.posts.last
    assert_equal user, post.author
    assert_equal content, post.content_markdown
    assert_equal it_2, post.iteration
    expected = {
      item: {
        uuid: post.uuid,
        author_handle: user.handle,
        author_flair: user.flair,
        author_avatar_url: user.avatar_url,
        by_student: true,
        content_markdown: content,
        content_html: "<p>#{content}</p>\n",
        updated_at: post.updated_at.iso8601,
        iteration_idx: 2,
        links: {
          edit: Exercism::Routes.api_solution_discussion_post_url(solution.uuid, discussion, post),
          delete: Exercism::Routes.api_solution_discussion_post_url(solution.uuid, discussion, post)
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
    discussion = create(:mentor_discussion, solution:)

    patch api_solution_discussion_post_path(solution.uuid, discussion, 1), headers: @headers, as: :json

    assert_response :not_found
    expected = { error: {
      type: "mentor_discussion_post_not_found",
      message: I18n.t("api.errors.mentor_discussion_post_not_found")
    } }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "returns 403 error when discussion cannot be accessed" do
    student = create(:user)
    setup_user(student)
    discussion_post = create(:mentor_discussion_post)

    patch api_solution_discussion_post_path(
      discussion_post.discussion.solution.uuid,
      discussion_post.discussion,
      discussion_post
    ), headers: @headers, as: :json

    assert_response :forbidden
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
    discussion = create(:mentor_discussion, solution:)
    discussion_post = create(:mentor_discussion_post, discussion:, author: create(:user))

    patch api_solution_discussion_post_path(solution.uuid, discussion, discussion_post), headers: @headers, as: :json

    assert_response :forbidden
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
    discussion = create(:mentor_discussion, solution:)
    discussion_post = create(:mentor_discussion_post, author: student, discussion:)

    patch api_solution_discussion_post_path(solution.uuid, discussion, discussion_post),
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

  test "updates a post" do
    student = create(:user, handle: "student")
    setup_user(student)
    solution = create :concept_solution, user: student
    discussion = create(:mentor_discussion, solution:)

    iteration = create :iteration, idx: 1
    discussion_post = create(:mentor_discussion_post,
      discussion:,
      author: student,
      iteration:,
      content_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25))

    patch api_solution_discussion_post_path(solution.uuid, discussion, discussion_post),
      params: { content: "content" },
      headers: @headers,
      as: :json

    assert_response :ok

    discussion_post.reload
    expected = {
      item: {
        uuid: discussion_post.uuid,
        author_handle: "student",
        author_flair: student.flair,
        author_avatar_url: student.avatar_url,
        by_student: true,
        content_markdown: "content",
        content_html: "<p>content</p>\n",
        updated_at: discussion_post.updated_at.iso8601,
        iteration_idx: 1,
        links: {
          edit: Exercism::Routes.api_solution_discussion_post_url(solution.uuid, discussion, discussion_post),
          delete: Exercism::Routes.api_solution_discussion_post_url(solution.uuid, discussion, discussion_post)
        }
      }
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  ###
  # Destroy
  ###
  test "destroy returns 404 error when post not found" do
    student = create(:user)
    setup_user(student)
    solution = create :concept_solution, user: student
    discussion = create(:mentor_discussion, solution:)

    delete api_solution_discussion_post_path(solution.uuid, discussion, 1), headers: @headers, as: :json

    assert_response :not_found
    expected = { error: {
      type: "mentor_discussion_post_not_found",
      message: I18n.t("api.errors.mentor_discussion_post_not_found")
    } }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "destroy returns 403 error when discussion cannot be accessed" do
    student = create(:user)
    setup_user(student)
    discussion_post = create(:mentor_discussion_post)

    delete api_solution_discussion_post_path(
      discussion_post.discussion.solution.uuid,
      discussion_post.discussion,
      discussion_post
    ), headers: @headers, as: :json

    assert_response :forbidden
    expected = { error: {
      type: "mentor_discussion_not_accessible",
      message: I18n.t("api.errors.mentor_discussion_not_accessible")
    } }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "destroy returns 403 error when post cannot be accessed" do
    student = create(:user)
    setup_user(student)
    solution = create :concept_solution, user: student
    discussion = create(:mentor_discussion, solution:)
    discussion_post = create(:mentor_discussion_post, discussion:, author: create(:user))

    delete api_solution_discussion_post_path(solution.uuid, discussion, discussion_post), headers: @headers, as: :json

    assert_response :forbidden
    expected = { error: {
      type: "mentor_discussion_post_not_accessible",
      message: I18n.t("api.errors.mentor_discussion_post_not_accessible")
    } }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "deletes a post" do
    student = create(:user, handle: "student")
    setup_user(student)
    solution = create :concept_solution, user: student
    discussion = create(:mentor_discussion, solution:)
    iteration = create :iteration, idx: 1
    discussion_post = create(:mentor_discussion_post,
      discussion:,
      author: student,
      iteration:,
      content_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25))

    delete api_solution_discussion_post_path(solution.uuid, discussion, discussion_post), headers: @headers, as: :json

    assert_response :ok

    expected = {
      item: {
        uuid: discussion_post.uuid,
        author_handle: "student",
        author_flair: student.flair,
        author_avatar_url: student.avatar_url,
        by_student: true,
        content_markdown: "Hello",
        content_html: "<p>Hello</p>\n",
        updated_at: discussion_post.updated_at.iso8601,
        iteration_idx: 1,
        links: {
          edit: Exercism::Routes.api_solution_discussion_post_url(solution.uuid, discussion, discussion_post),
          delete: Exercism::Routes.api_solution_discussion_post_url(solution.uuid, discussion, discussion_post)
        }
      }
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
    refute Mentor::DiscussionPost.exists?(discussion.id)
  end
end
