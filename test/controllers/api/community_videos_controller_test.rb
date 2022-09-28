require_relative './base_test_case'

class API::CommunitySolutionCommentsControllerTest < API::BaseTestCase
  guard_incorrect_token! :lookup_api_community_videos_path, method: :get
  guard_incorrect_token! :api_community_videos_path, method: :post

  ###
  # Lookup
  ###
  test "lookup returns video" do
    user = create :user
    url = "https://youtube.com/..."
    video = build :community_video, url: url
    CommunityVideo::Retrieve.expects(:call).with(url).returns(video)

    setup_user(user)

    get lookup_api_community_videos_path(video_url: url), headers: @headers, as: :json

    assert_response :ok
    expected = {
      community_video: {
        title: video.title, platform: video.platform.to_s, channel_name: video.channel_name, thumbnail_url: video.thumbnail_url
      }
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "lookup should return 400 when video url is incorrect" do
    setup_user

    get lookup_api_community_videos_path(video_url: "https://example.com/..."), headers: @headers, as: :json

    assert_response 400
    expected = { error: {
      type: "invalid_community_video_url",
      message: I18n.t('api.errors.invalid_community_video_url')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  ###
  # Create
  ###
  # test "create should 404 if the solution doesn't exist" do
  #   setup_user
  #   solution = create :practice_solution
  #   post api_community_solution_comments_path(
  #     solution.track, solution.exercise, "foobar123"
  #   ), headers: @headers, as: :json
  #   assert_response :not_found
  #   expected = { error: {
  #     type: "solution_not_found",
  #     message: I18n.t('api.errors.solution_not_found')
  #   } }
  #   actual = JSON.parse(response.body, symbolize_names: true)
  #   assert_equal expected, actual
  # end

  # test "create should return 403 when solution is not published" do
  #   setup_user
  #   solution = create :practice_solution

  #   post api_community_solution_comments_path(
  #     solution.track, solution.exercise, solution.user.handle
  #   ), headers: @headers, as: :json

  #   assert_response :forbidden
  #   expected = { error: {
  #     type: "solution_comments_not_allowed",
  #     message: I18n.t('api.errors.solution_comments_not_allowed')
  #   } }
  #   actual = JSON.parse(response.body, symbolize_names: true)
  #   assert_equal expected, actual
  # end

  test "create should create correctly for user" do
    user = create :user
    title = "foooooo"
    url = "https://youtube.com/..."
    video = build :community_video, url: url
    CommunityVideo::Retrieve.expects(:call).with(url).returns(video)

    setup_user(user)

    post api_community_videos_path,
      params: { video_url: url, title: },
      headers: @headers, as: :json

    assert_response :ok

    video = CommunityVideo.last
    assert_equal user, video.submitted_by
    assert_equal title, video.title
    assert_nil video.author
    assert_nil video.exercise
    assert_nil video.track

    expected = {}
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "create sets author if specified" do
    user = create :user
    url = "https://youtube.com/..."
    video = build :community_video, url: url
    CommunityVideo::Retrieve.expects(:call).with(url).returns(video)

    setup_user(user)

    post api_community_videos_path,
      params: { video_url: url, submitter_is_author: true },
      headers: @headers, as: :json

    assert_response :ok

    video = CommunityVideo.last
    assert_equal user, video.submitted_by
    assert_equal user, video.author
  end

  test "create sets exercise if specified" do
    user = create :user
    url = "https://youtube.com/..."
    exercise = create :practice_exercise
    video = build :community_video, url: url
    CommunityVideo::Retrieve.expects(:call).with(url).returns(video)

    setup_user(user)

    post api_community_videos_path,
      params: { video_url: url, track_slug: exercise.track.slug, exercise_slug: exercise.slug },
      headers: @headers, as: :json

    assert_response :ok

    video = CommunityVideo.last
    assert_equal exercise, video.exercise
    assert_equal exercise.track, video.track
  end
end
