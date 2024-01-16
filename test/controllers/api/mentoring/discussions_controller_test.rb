require_relative '../base_test_case'

class API::Mentoring::DiscussionsControllerTest < API::BaseTestCase
  include Propshaft::Helper

  guard_incorrect_token! :api_mentoring_discussions_path
  guard_incorrect_token! :tracks_api_mentoring_discussions_path
  guard_incorrect_token! :api_mentoring_discussions_path, method: :post
  guard_incorrect_token! :mark_as_nothing_to_do_api_mentoring_discussion_path, args: 1, method: :patch

  ###
  # Index
  ###
  test "index proxies correctly" do
    user = create :user
    setup_user(user)

    ::Mentor::Discussion::Retrieve.expects(:call).with(
      user,
      'status_param',
      page: 'page_param',
      track_slug: 'track_param',
      student_handle: 'student_param',
      criteria: 'criteria_param',
      order: 'order_param',
      exclude_uuid: 'exclude_uuid'
    ).returns(mock(includes: [], total_count: 200, current_page: 1, total_pages: 1))

    get api_mentoring_discussions_path, params: {
      status: 'status_param',
      page: 'page_param',
      track_slug: 'track_param',
      student: 'student_param',
      criteria: 'criteria_param',
      order: 'order_param',
      exclude_uuid: 'exclude_uuid'
    }, headers: @headers, as: :json
  end

  test "index retrieves discussions" do
    user = create :user
    setup_user(user)

    create :mentor_discussion, :awaiting_mentor, mentor: user

    get api_mentoring_discussions_path(status: :awaiting_mentor),
      headers: @headers, as: :json
    assert_response :ok

    expected = SerializePaginatedCollection.(
      Mentor::Discussion.page(1).per(10),
      serializer: SerializeMentorDiscussionsForMentor,
      serializer_args: :mentor,
      meta: {}
    )

    assert_equal JSON.parse(expected.to_json), JSON.parse(response.body)
  end

  test "index sideloads meta" do
    user = create :user
    setup_user(user)

    create :mentor_discussion, :awaiting_mentor, mentor: user

    get api_mentoring_discussions_path(status: :awaiting_mentor, sideload: [:all_discussion_counts]),
      headers: @headers, as: :json
    assert_response :ok

    expected = SerializePaginatedCollection.(
      Mentor::Discussion.page(1).per(10),
      serializer: SerializeMentorDiscussionsForMentor,
      serializer_args: :mentor,
      meta: {
        awaiting_mentor_total: 1,
        awaiting_student_total: 0,
        finished_total: 0
      }
    )

    assert_equal JSON.parse(expected.to_json), JSON.parse(response.body)
  end

  test "index returns 404 when status is invalid" do
    user = create :user
    setup_user(user)

    create :mentor_discussion, :awaiting_mentor, mentor: user

    get api_mentoring_discussions_path(status: :unknown),
      headers: @headers, as: :json

    assert_response :bad_request
    assert_equal(
      {
        "error" => {
          "type" => "invalid_discussion_status",
          "message" => I18n.t("api.errors.invalid_discussion_status")
        }
      },
      JSON.parse(response.body)
    )
  end

  ###
  # Tracks
  ###

  test "tracks retrieves all tracks sorted by title, including those not on current page" do
    user = create :user
    setup_user(user)

    ruby = create :track, title: "Ruby", slug: "ruby"
    go = create :track, title: "Go", slug: "go"

    series = create :concept_exercise, title: "Series", track: ruby
    series_solution = create :concept_solution, exercise: series
    create :mentor_discussion, :awaiting_mentor, solution: series_solution, mentor: @current_user

    tournament = create :concept_exercise, title: "Tournament", track: go
    tournament_solution = create :concept_solution, exercise: tournament
    create :mentor_discussion, :awaiting_mentor, solution: tournament_solution, mentor: @current_user
    create :mentor_discussion, :awaiting_mentor, solution: tournament_solution, mentor: @current_user

    get tracks_api_mentoring_discussions_path(per: 1, status: :awaiting_mentor), headers: @headers, as: :json
    assert_response :ok

    expected = [
      { slug: nil, title: 'All Tracks', icon_url: nil, count: 3 },
      { slug: go.slug, title: go.title, icon_url: go.icon_url, count: 2 },
      { slug: ruby.slug, title: ruby.title, icon_url: ruby.icon_url, count: 1 }
    ]
    assert_equal JSON.parse(expected.to_json), JSON.parse(response.body)
  end

  ###
  # Create
  ###

  test "create should 404 if the request doesn't exist" do
    setup_user

    post api_mentoring_discussions_path(mentor_request_id: 'xxx'), headers: @headers, as: :json
    assert_response :not_found
    expected = { error: {
      type: "mentor_request_not_found",
      message: I18n.t('api.errors.mentor_request_not_found')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should 400 if the request is locked" do
    setup_user

    mentor_request = create :mentor_request
    create :mentor_request_lock, request: mentor_request
    post api_mentoring_discussions_path(mentor_request_uuid: mentor_request), headers: @headers, as: :json
    assert_response :bad_request
    expected = { error: {
      type: "mentor_request_locked",
      message: I18n.t('api.errors.mentor_request_locked')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should 400 if the mentor is also the student" do
    user = create :user
    setup_user(user)

    solution = create(:practice_solution, user:)
    submission = create(:submission, solution:)
    create(:iteration, submission:)
    mentor_request = create(:mentor_request, solution:)

    post api_mentoring_discussions_path(mentor_request_uuid: mentor_request), headers: @headers, as: :json
    assert_response :bad_request
    expected = { error: {
      type: "student_cannot_mentor_themselves",
      message: I18n.t('api.errors.student_cannot_mentor_themselves')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "create should create correctly" do
    user = create :user
    setup_user(user)
    solution = create :concept_solution
    create :iteration, solution:, idx: 1
    it_2 = create :iteration, solution:, idx: 2
    mentor_request = create(:mentor_request, solution:)

    content = "foo to the baaar"

    post api_mentoring_discussions_path,
      params: {
        iteration_idx: 2,
        mentor_request_uuid: mentor_request.uuid,
        content:
      },
      headers: @headers, as: :json

    assert_response :ok

    discussion = Mentor::Discussion.last
    assert_equal mentor_request, discussion.request
    assert_equal user, discussion.mentor
    assert_equal solution, discussion.solution
    post = discussion.posts.last
    assert_equal user, post.author
    assert_equal content, post.content_markdown
    assert_equal it_2, post.iteration
  end

  ###
  # MARK AS NOTHING TO DO
  ###

  test "mark_as_nothing_to_do should return 404 when the discussion does not exist" do
    setup_user

    patch mark_as_nothing_to_do_api_mentoring_discussion_path(1), headers: @headers, as: :json

    assert_response :not_found
    expected = { error: {
      type: "mentor_discussion_not_found",
      message: I18n.t("api.errors.mentor_discussion_not_found")
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "mark_as_nothing_to_do should return 403 when the discussion is not accessible" do
    setup_user
    discussion = create :mentor_discussion

    patch mark_as_nothing_to_do_api_mentoring_discussion_path(discussion), headers: @headers, as: :json

    assert_response :forbidden
    expected = { error: {
      type: "mentor_discussion_not_accessible",
      message: I18n.t("api.errors.mentor_discussion_not_accessible")
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "mark_as_nothing_to_do should return 403 when the user is not the mentor" do
    setup_user
    solution = create :concept_solution, user: @current_user
    discussion = create(:mentor_discussion, solution:)

    patch mark_as_nothing_to_do_api_mentoring_discussion_path(discussion), headers: @headers, as: :json

    assert_response :forbidden
    expected = { error: {
      type: "mentor_discussion_not_accessible",
      message: I18n.t("api.errors.mentor_discussion_not_accessible")
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "mark_as_nothing_to_do should return 200 when the discussion is not accessible" do
    setup_user
    discussion = create :mentor_discussion, mentor: @current_user

    patch mark_as_nothing_to_do_api_mentoring_discussion_path(discussion), headers: @headers, as: :json

    assert_response :ok
    discussion.reload
    refute discussion.awaiting_mentor?
  end
end
