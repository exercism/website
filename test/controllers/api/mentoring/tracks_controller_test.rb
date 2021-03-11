require_relative '../base_test_case'

class API::Mentoring::TracksControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_mentoring_tracks_path
  guard_incorrect_token! :mentored_api_mentoring_tracks_path
  guard_incorrect_token! :api_mentoring_tracks_path, args: 1, method: :put

  ###
  # Index
  ###
  test "index retrieves all tracks" do
    user = create :user
    track = create :track
    create :track, slug: :javascript
    create :user_track_mentorship, user: user, track: track
    setup_user(user)

    get api_mentoring_tracks_path, headers: @headers, as: :json
    assert_response 200

    expected = SerializeTracksForMentoring.(Track.all, mentor: user)
    assert_equal expected.to_json, response.body
  end

  ###
  # Mentored
  ###
  test "mentored retrieves mentored tracks" do
    user = create :user
    track = create :track
    create :track, slug: :javascript
    create :user_track_mentorship, user: user, track: track
    setup_user(user)

    get mentored_api_mentoring_tracks_path, headers: @headers, as: :json
    assert_response 200

    expected = SerializeTracksForMentoring.(Track.where(id: track.id), mentor: user)
    assert_equal expected.to_json, response.body
  end

  ###
  # Lock
  ###
  test "update should update" do
    user = create :user
    ruby = create :track
    javascript = create :track, slug: :javascript
    create :user_track_mentorship, user: user, track: ruby
    setup_user(user)

    assert_equal [ruby], user.mentored_tracks # Sanity

    put api_mentoring_tracks_path(track_slugs: [:javascript]), headers: @headers, as: :json
    assert_response 200

    assert_equal [javascript], user.reload.mentored_tracks
    expected = SerializeTracksForMentoring.(Track.where(id: javascript.id), mentor: user)
    assert_equal expected.to_json, response.body
  end
end
