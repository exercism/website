require_relative '../base_test_case'

class API::Mentoring::DiscussionPostsControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_mentoring_discussion_posts_path, args: 1, method: :post
  guard_incorrect_token! :api_mentoring_discussion_posts_path, args: 2, method: :get

  ###
  # Index
  ###
  test "index returns posts for request and discussion" do
    student = create :user, handle: "student"
    mentor = create :user, handle: "author"
    setup_user(mentor)
    solution = create :concept_solution, user: student
    mentor_request = create :mentor_request,
      solution:,
      comment_markdown: "Welcome",
      created_at: Time.utc(2016, 12, 25)
    discussion = create :mentor_discussion, solution:, mentor:, request: mentor_request
    iteration = create(:iteration, idx: 2, solution:)
    discussion_post = create(:mentor_discussion_post,
      discussion:,
      iteration:,
      author: mentor,
      content_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25))

    get api_mentoring_discussion_posts_path(discussion), headers: @headers, as: :json

    assert_response :ok
    expected = {
      items: [
        {
          uuid: "request-comment",
          author_handle: "student",
          author_flair: nil,
          author_avatar_url: student.avatar_url,
          by_student: true,
          content_markdown: "Welcome",
          content_html: "<p>Welcome</p>\n",
          updated_at: Time.utc(2016, 12, 25).iso8601,
          iteration_idx: 2,
          links: {}
        },
        {
          uuid: discussion_post.uuid,
          author_handle: "author",
          author_flair: nil,
          author_avatar_url: mentor.avatar_url,
          by_student: false,
          content_markdown: "Hello",
          content_html: "<p>Hello</p>\n",
          updated_at: Time.utc(2016, 12, 25).iso8601,
          iteration_idx: 2,
          links: {
            edit: Exercism::Routes.api_mentoring_discussion_post_url(discussion, discussion_post),
            delete: Exercism::Routes.api_mentoring_discussion_post_url(discussion, discussion_post)
          }
        }
      ]
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "index returns just mentor request comment" do
    student = create :user, handle: "student"
    mentor = create :user, handle: "author"
    setup_user(mentor)
    solution = create :concept_solution, user: student
    mentor_request = create :mentor_request,
      solution:,
      comment_markdown: "Hello",
      created_at: Time.utc(2016, 12, 25)
    discussion = create :mentor_discussion, solution:, mentor:, request: mentor_request
    create(:iteration, idx: 7, solution:)

    get api_mentoring_discussion_posts_path(discussion), headers: @headers, as: :json

    assert_response :ok
    expected = {
      items: [
        {
          uuid: "request-comment",
          author_handle: "student",
          author_flair: nil,
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

  test "index shows for admin user who is not mentor or student" do
    admin = create :user, :admin
    sign_in!(admin)

    solution = create :concept_solution
    discussion = create(:mentor_discussion, solution:)
    create(:iteration, solution:)
    get api_mentoring_discussion_posts_path(discussion), headers: @headers, as: :json

    assert_response :ok
  end

  test "index should return 403 when discussion can not be accessed" do
    setup_user
    discussion = create :mentor_discussion
    iteration = create :iteration

    get api_mentoring_discussion_posts_path(discussion, iteration_idx: iteration.idx), headers: @headers, as: :json

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
    setup_user
    post api_mentoring_discussion_posts_path('xxx'), headers: @headers, as: :json
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

    post api_mentoring_discussion_posts_path(discussion), headers: @headers, as: :json

    assert_response :forbidden
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
    create :iteration, solution:, idx: 1
    it_2 = create :iteration, solution:, idx: 2
    discussion = create :mentor_discussion,
      solution:,
      mentor: user

    # Check we're calling the correet class
    User::Notification::Create.expects(:call).with(
      solution.user,
      :mentor_replied_to_discussion,
      anything
    )

    content = "foo to the baaar"

    post api_mentoring_discussion_posts_path(discussion),
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
        author_flair: nil,
        author_avatar_url: user.avatar_url,
        by_student: false,
        content_markdown: content,
        content_html: "<p>#{content}</p>\n",
        updated_at: post.updated_at.iso8601,
        iteration_idx: 2,
        links: {
          edit: Exercism::Routes.api_mentoring_discussion_post_url(post.discussion, post),
          delete: Exercism::Routes.api_mentoring_discussion_post_url(post.discussion, post)
        }
      }
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "create should create correctly for student" do
    skip
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
    post api_mentoring_discussion_posts_path(discussion),
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
        id: post.uuid,
        author_handle: user.handle,
        author_flair: nil,
        author_avatar_url: user.avatar_url,
        by_student: true,
        content_markdown: content,
        content_html: "<p>#{content}</p>\n",
        updated_at: post.updated_at.iso8601,
        iteration_idx: 2,
        links: {
          self: Exercism::Routes.api_mentoring_discussion_post_url(post.discussion, post)
        }
      }
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  ###
  # Update
  ###
  test "returns 404 error when post not found" do
    mentor = create(:user)
    setup_user(mentor)
    discussion = create(:mentor_discussion, mentor:)

    patch api_mentoring_discussion_post_path(discussion, 1), headers: @headers, as: :json

    assert_response :not_found
    expected = { error: {
      type: "mentor_discussion_post_not_found",
      message: I18n.t("api.errors.mentor_discussion_post_not_found")
    } }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "returns 403 error when discussion cannot be accessed" do
    mentor = create(:user)
    setup_user(mentor)
    discussion_post = create(:mentor_discussion_post)

    patch api_mentoring_discussion_post_path(discussion_post.discussion, discussion_post), headers: @headers, as: :json

    assert_response :forbidden
    expected = { error: {
      type: "mentor_discussion_not_accessible",
      message: I18n.t("api.errors.mentor_discussion_not_accessible")
    } }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "returns 403 error when post cannot be accessed" do
    mentor = create(:user)
    setup_user(mentor)
    discussion = create(:mentor_discussion, mentor:)
    discussion_post = create(:mentor_discussion_post, discussion:, author: create(:user))

    patch api_mentoring_discussion_post_path(discussion, discussion_post), headers: @headers, as: :json

    assert_response :forbidden
    expected = { error: {
      type: "mentor_discussion_post_not_accessible",
      message: I18n.t("api.errors.mentor_discussion_post_not_accessible")
    } }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "returns 400 when validations fail" do
    mentor = create(:user)
    setup_user(mentor)
    discussion = create(:mentor_discussion, mentor:)
    discussion_post = create(:mentor_discussion_post, author: mentor, discussion:)

    patch api_mentoring_discussion_post_path(discussion, discussion_post),
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
    mentor = create(:user, handle: "mentor")
    setup_user(mentor)
    discussion = create(:mentor_discussion, mentor:)

    iteration = create :iteration, idx: 1
    discussion_post = create(:mentor_discussion_post,
      discussion:,
      author: mentor,
      iteration:,
      content_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25))

    patch api_mentoring_discussion_post_path(discussion, discussion_post),
      params: { content: "content" },
      headers: @headers,
      as: :json

    assert_response :ok

    discussion_post.reload
    expected = {
      item: {
        uuid: discussion_post.uuid,
        author_handle: "mentor",
        author_flair: nil,
        author_avatar_url: mentor.avatar_url,
        by_student: false,
        content_markdown: "content",
        content_html: "<p>content</p>\n",
        updated_at: discussion_post.updated_at.iso8601,
        iteration_idx: 1,
        links: {
          edit: Exercism::Routes.api_mentoring_discussion_post_url(discussion_post.discussion, discussion_post),
          delete: Exercism::Routes.api_mentoring_discussion_post_url(discussion_post.discussion, discussion_post)
        }
      }
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  ###
  # Destroy
  ###
  test "destroy returns 404 error when post not found" do
    mentor = create(:user)
    setup_user(mentor)
    discussion = create(:mentor_discussion, mentor:)

    delete api_mentoring_discussion_post_path(discussion, 1), headers: @headers, as: :json

    assert_response :not_found
    expected = { error: {
      type: "mentor_discussion_post_not_found",
      message: I18n.t("api.errors.mentor_discussion_post_not_found")
    } }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "destroy returns 403 error when discussion cannot be accessed" do
    mentor = create(:user)
    setup_user(mentor)
    discussion_post = create(:mentor_discussion_post)

    delete api_mentoring_discussion_post_path(discussion_post.discussion, discussion_post), headers: @headers, as: :json

    assert_response :forbidden
    expected = { error: {
      type: "mentor_discussion_not_accessible",
      message: I18n.t("api.errors.mentor_discussion_not_accessible")
    } }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "destroy returns 403 error when post cannot be accessed" do
    mentor = create(:user)
    setup_user(mentor)
    discussion = create(:mentor_discussion, mentor:)
    discussion_post = create(:mentor_discussion_post, discussion:, author: create(:user))

    delete api_mentoring_discussion_post_path(discussion, discussion_post), headers: @headers, as: :json

    assert_response :forbidden
    expected = { error: {
      type: "mentor_discussion_post_not_accessible",
      message: I18n.t("api.errors.mentor_discussion_post_not_accessible")
    } }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "destroys a post" do
    mentor = create(:user, handle: "mentor")
    setup_user(mentor)
    discussion = create(:mentor_discussion, mentor:)
    iteration = create :iteration, idx: 1
    discussion_post = create(:mentor_discussion_post,
      discussion:,
      author: mentor,
      iteration:,
      content_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25))

    delete api_mentoring_discussion_post_path(discussion, discussion_post),
      params: { content: "content" },
      headers: @headers,
      as: :json

    assert_response :ok
    expected = {
      item: {
        uuid: discussion_post.uuid,
        author_handle: "mentor",
        author_flair: nil,
        author_avatar_url: mentor.avatar_url,
        by_student: false,
        content_markdown: "Hello",
        content_html: "<p>Hello</p>\n",
        updated_at: discussion_post.updated_at.iso8601,
        iteration_idx: 1,
        links: {
          edit: Exercism::Routes.api_mentoring_discussion_post_url(discussion_post.discussion, discussion_post),
          delete: Exercism::Routes.api_mentoring_discussion_post_url(discussion_post.discussion, discussion_post)
        }
      }
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
    refute Mentor::DiscussionPost.exists?(discussion_post.id)
  end
end
