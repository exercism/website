require_relative './base_test_case'

class API::TracksControllerTest < API::BaseTestCase
  test "index should filter correctly" do
    user = create :user
    setup_user(user)

    track_1 = create :track, slug: :ruby, title: "Ruby Joined"
    track_2 = create :track, slug: :js, title: "JS FOobar"
    create :track, slug: :ruby_unjoined, title: "Ruby Unjoined"

    create :user_track, user:, track: track_1
    create :user_track, user:, track: track_2

    get api_tracks_url(
      criteria: "ruby",
      status: "joined"
    ), headers: @headers, as: :json
    assert_response :ok

    expected = { tracks: SerializeTracks.([track_1], user) }.to_json
    assert_equal expected, response.body
  end

  test "show should return track if the track is active" do
    setup_user
    track = create :track, active: true
    get api_track_path(track.slug), headers: @headers, as: :json

    assert_response :ok
    expected = {
      track: {
        slug: track.slug,
        language: track.title
      }
    }.to_json
    assert_equal expected, response.body
  end

  test "show should return track if the track is inactive and the user is a maintainer" do
    user = create :user, roles: [:maintainer]
    setup_user(user)
    track = create :track, active: false
    get api_track_path(track.slug), headers: @headers, as: :json

    assert_response :ok
    expected = {
      track: {
        slug: track.slug,
        language: track.title
      }
    }.to_json
    assert_equal expected, response.body
  end

  test "show should 404 if the track is inactive and the user is not a maintainer" do
    user = create :user, roles: []
    setup_user(user)
    track = create :track, active: false
    get api_track_path(track.slug), headers: @headers, as: :json

    assert_response :not_found
    expected = { error: {
      type: "track_not_found",
      message: I18n.t('api.errors.track_not_found'),
      fallback_url: "http://test.exercism.org/tracks"
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end
end
