require_relative './base_test_case'

class API::MentorDiscussionPostsControllerTest < API::BaseTestCase
  ###
  # Index
  ###
  test "index returns posts for discussion and iteration" do
    student = create :user, handle: "student"
    mentor = create :user, handle: "author"
    setup_user(mentor)
    solution = create :concept_solution, user: student
    mentor_request = create :solution_mentor_request,
      solution: solution,
      comment: "Hello",
      updated_at: Time.utc(2016, 12, 25)
    discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor, request: mentor_request
    iteration = create :iteration, idx: 2, solution: solution
    discussion_post = create(:solution_mentor_discussion_post,
      discussion: discussion,
      iteration: iteration,
      author: mentor,
      content_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25))

    get api_mentor_discussion_posts_path(discussion), headers: @headers, as: :json

    assert_response 200
    expected = {
      posts: [
        {
          id: "uuid",
          author_id: student.id,
          author_handle: "student",
          author_avatar_url: student.avatar_url,
          by_student: true,
          content_markdown: "Hello",
          content_html: "Hello",
          updated_at: Time.utc(2016, 12, 25).iso8601,
          iteration_idx: 2,
          links: {}
        },
        {
          id: discussion_post.uuid,
          author_id: mentor.id,
          author_handle: "author",
          author_avatar_url: mentor.avatar_url,
          by_student: false,
          content_markdown: "Hello",
          content_html: "<p>Hello</p>\n",
          updated_at: Time.utc(2016, 12, 25).iso8601,
          iteration_idx: 2,
          links: {
            update: Exercism::Routes.api_mentor_discussion_post_url(discussion_post)
          }
        }
      ]
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "index returns mentor request comment for the last iteration if no posts exist yet" do
    student = create :user, handle: "student"
    mentor = create :user, handle: "author"
    setup_user(mentor)
    solution = create :concept_solution, user: student
    mentor_request = create :solution_mentor_request,
      solution: solution,
      comment: "Hello",
      updated_at: Time.utc(2016, 12, 25)
    discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor, request: mentor_request
    create :iteration, idx: 7, solution: solution

    get api_mentor_discussion_posts_path(discussion), headers: @headers, as: :json

    assert_response 200
    expected = {
      posts: [
        {
          id: "uuid",
          author_id: student.id,
          author_handle: "student",
          author_avatar_url: student.avatar_url,
          by_student: true,
          content_markdown: "Hello",
          content_html: "Hello",
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

    get api_mentor_discussion_posts_path(discussion, iteration_idx: iteration.idx), headers: @headers, as: :json

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

  test "create should return 403 when discussion can not be accessed" do
    setup_user
    discussion = create :solution_mentor_discussion

    post api_mentor_discussion_posts_path(discussion), headers: @headers, as: :json

    assert_response 403
    expected = { error: {
      type: "mentor_discussion_not_accessible",
      message: I18n.t('api.errors.mentor_discussion_not_accessible')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
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
    User::Notification::Create.expects(:call).with(
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
    expected = {
      post: {
        id: post.uuid,
        author_id: user.id,
        author_handle: user.handle,
        author_avatar_url: user.avatar_url,
        by_student: false,
        content_markdown: content,
        content_html: "<p>#{content}</p>\n",
        updated_at: post.updated_at.iso8601,
        iteration_idx: 2,
        links: {
          update: Exercism::Routes.api_mentor_discussion_post_url(post)
        }
      }
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "create should create correctly for student" do
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
          update: Exercism::Routes.api_mentor_discussion_post_url(post)
        }
      }
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  ###
  # Update
  ###
  test "returns 404 error when post not found" do
    setup_user

    patch api_mentor_discussion_post_path(1), headers: @headers, as: :json

    assert_response 404
    expected = { error: {
      type: "mentor_discussion_post_not_found",
      message: I18n.t("api.errors.mentor_discussion_post_not_found")
    } }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "returns 403 error when post cannot be accessed" do
    setup_user
    discussion_post = create(:solution_mentor_discussion_post)

    patch api_mentor_discussion_post_path(discussion_post), headers: @headers, as: :json

    assert_response 403
    expected = { error: {
      type: "permission_denied",
      message: I18n.t("api.errors.permission_denied")
    } }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "returns 400 when validations fail" do
    author = create(:user)
    setup_user(author)
    discussion_post = create(:solution_mentor_discussion_post, author: author)

    patch api_mentor_discussion_post_path(discussion_post),
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
    author = create(:user, handle: "author")
    iteration = create :iteration, idx: 1
    discussion_post = create(:solution_mentor_discussion_post,
      author: author,
      iteration: iteration,
      content_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25))
    setup_user(author)

    patch api_mentor_discussion_post_path(discussion_post),
      params: { content: "content" },
      headers: @headers,
      as: :json

    assert_response 200

    discussion_post.reload
    expected = {
      post: {
        id: discussion_post.uuid,
        author_id: author.id,
        author_handle: "author",
        author_avatar_url: author.avatar_url,
        by_student: false,
        content_markdown: "content",
        content_html: "<p>content</p>\n",
        updated_at: discussion_post.updated_at.iso8601,
        iteration_idx: 1,
        links: {
          update: Exercism::Routes.api_mentor_discussion_post_url(discussion_post)
        }
      }
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end
end
