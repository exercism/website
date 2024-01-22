require "test_helper"

class TracksControllerTest < ActionDispatch::IntegrationTest
  test "index: renders correctly for external" do
    track = create :track

    get tracks_url(track)
    assert_template "tracks/index"
  end

  test "index: renders correctly for internal" do
    sign_in!

    track = create :track

    get tracks_url(track)
    assert_template "tracks/index"
  end

  test "show: 404s silently for missing track" do
    get track_url('foobar')

    assert_rendered_404
  end

  test "show: renders correctly for active track" do
    track = create :track, active: true

    get track_url(track)

    assert_response :ok
  end

  test "show: renders correctly for inactive track but user is a maintainer" do
    user = create :user, roles: [:maintainer]
    sign_in!(user)
    track = create :track, active: false
    create(:hello_world_exercise, track:)
    create(:user_track, user:, track:)

    stub_latest_track_forum_threads(track)

    get track_url(track)

    assert_response :ok
  end

  test "show: 404s silently for inactive track and user is not a maintainer" do
    user = create :user, roles: []
    sign_in!(user)
    track = create :track, active: false
    create(:user_track, user:, track:)

    get track_url(track)

    assert_rendered_404
  end

  test "about shows for joined member" do
    user = create :user
    track = create :track
    create(:practice_exercise, track:)
    create(:user_track, user:, track:)

    sign_in!(user)
    get about_track_url(track)

    assert_response :ok
  end

  test "about redirects for non-joined member" do
    track = create :track
    get about_track_url(track)

    sign_in!
    assert_redirected_to track_url(track)
  end

  test "about redirects for external user" do
    track = create :track
    get about_track_url(track)

    sign_in!
    assert_redirected_to track_url(track)
  end
end
