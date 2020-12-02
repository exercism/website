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

  test "params get passed correctly" do
    track_1 = create :track, title: "Ruby #{SecureRandom.uuid}"
    track_2 = create :track, title: "JS #{SecureRandom.uuid}"
    track_3 = create :track, title: "Ruby #{SecureRandom.uuid}"

    user = create :user
    create :user_track, user: user, track: track_1
    create :user_track, user: user, track: track_2

    sign_in!(user)

    get tracks_url(
      criteria: "ruby",
      status: "joined"
    )
    assert_response :success

    # Assert only the track that matches the criteria
    # is retrieved and served.
    #
    # Is this going to work with React? If not,
    # should we have this as a system test instead?
    assert_includes @response.body, track_1.title
    refute_includes @response.body, track_2.title
    refute_includes @response.body, track_3.title
  end
end
