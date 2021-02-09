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
    ruby_1 = create :track, slug: :ruby_1, title: "Ruby #{SecureRandom.hex}"
    js = create :track, slug: :js, title: "JS #{SecureRandom.hex}"
    ruby_2 = create :track, slug: :ruby_2, title: "Ruby #{SecureRandom.hex}"

    user = create :user
    create :user_track, user: user, track: ruby_1
    create :user_track, user: user, track: js

    sign_in!(user)

    get tracks_url(
      criteria: "ruby",
      status: "joined"
    )
    assert_response :success

    # Assert only the track that matches the criteria
    # is retrieved and served.
    assert_includes @response.body, ruby_1.title
    refute_includes @response.body, js.title
    refute_includes @response.body, ruby_2.title
  end
end
