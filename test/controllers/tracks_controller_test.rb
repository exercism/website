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
end
