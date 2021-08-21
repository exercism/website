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

  test "about shows for joined member" do
    user = create :user
    track = create :track
    create :practice_exercise, track: track
    create :user_track, user: user, track: track

    sign_in!(user)
    get about_track_url(track)

    assert_response 200
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
