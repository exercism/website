require_relative './base_test_case'

class API::TracksControllerTest < API::BaseTestCase
  test "index should filter correctly" do
    user = create :user
    setup_user(user)

    track_1 = create :track, slug: :ruby, title: "Ruby Joined"
    track_2 = create :track, slug: :js, title: "JS FOobar"
    create :track, slug: :ruby_unjoined, title: "Ruby Unjoined"

    create :user_track, user: user, track: track_1
    create :user_track, user: user, track: track_2

    get api_tracks_url(
      criteria: "ruby",
      status: "joined"
    ), headers: @headers, as: :json
    assert_response 200

    expected = { tracks: SerializeTracks.([track_1], user) }.to_json
    assert_equal expected, response.body
  end
end
