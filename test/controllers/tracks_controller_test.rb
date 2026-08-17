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

  # The updates article is wrapped in a fragment cache, and perform_caching is
  # off for the rest of the suite, so without turning it on here nothing would
  # ever exercise the cached branch of that block.
  test "show: renders the cached updates article on both a miss and a hit" do
    user = create :user
    track = create :track, active: true
    create(:hello_world_exercise, track:)
    create(:user_track, user:, track:)

    stub_latest_track_forum_threads(track)
    sign_in!(user)

    with_caching do
      get track_url(track)

      assert_response :ok
      assert_select "section.contributors-section"
      assert_select "section.updates-section"

      # Proves the second render is served from the fragment rather than being
      # rebuilt: the contributor search is the expensive thing inside it.
      Track.any_instance.expects(:top_contributors).never

      get track_url(track)

      assert_response :ok
      assert_select "section.contributors-section"
      assert_select "section.updates-section"
    end
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
