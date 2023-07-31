require_relative '../base_test_case'

class API::Mentoring::TracksControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_mentoring_tracks_path
  guard_incorrect_token! :mentored_api_mentoring_tracks_path
  guard_incorrect_token! :api_mentoring_tracks_path, args: 1, method: :put

  ###
  # Show
  ###
  test "show retrieves all tracks" do
    user = create :user
    track = create :track
    create :track, slug: :javascript
    create(:user_track_mentorship, user:, track:)
    setup_user(user)

    get api_mentoring_tracks_path, headers: @headers, as: :json
    assert_response :ok

    expected = {
      tracks: SerializeTracksForMentoring.(Track.all, user)
    }
    assert_equal expected.to_json, response.body
  end

  test "show filters correctly" do
    user = create :user
    create :track, slug: :javascript, title: "Javascript"
    ruby = create :track, slug: :ruby, title: "Ruby"
    setup_user(user)

    get api_mentoring_tracks_path, headers: @headers, as: :json,
      params: { criteria: "ruby" }
    assert_response :ok

    expected = {
      tracks: SerializeTracksForMentoring.(Track.where(id: ruby.id), user)
    }
    assert_equal expected.to_json, response.body
  end

  ###
  # Mentored
  ###
  test "mentored retrieves mentored tracks" do
    user = create :user
    track = create :track
    create :track, slug: :javascript
    create(:user_track_mentorship, user:, track:)
    setup_user(user)

    get mentored_api_mentoring_tracks_path, headers: @headers, as: :json
    assert_response :ok

    expected = {
      tracks: SerializeTracksForMentoring.(Track.where(id: track.id), user)
    }
    assert_equal expected.to_json, response.body
  end

  test "mentored filters correctly" do
    user = create :user
    js = create :track, slug: :javascript, title: "Javascript"
    ruby = create :track, slug: :ruby, title: "Ruby"
    create :user_track_mentorship, user:, track: js
    create :user_track_mentorship, user:, track: ruby
    setup_user(user)

    get mentored_api_mentoring_tracks_path, headers: @headers, as: :json,
      params: { criteria: "ruby" }
    assert_response :ok

    expected = {
      tracks: SerializeTracksForMentoring.(Track.where(id: ruby.id), user)
    }
    assert_equal expected.to_json, response.body
  end

  ###
  # Lock
  ###
  test "update should update" do
    user = create :user
    ruby = create :track
    javascript = create :track, slug: :javascript
    create :user_track_mentorship, user:, track: ruby
    setup_user(user)

    assert_equal [ruby], user.mentored_tracks # Sanity

    put api_mentoring_tracks_path(track_slugs: [:javascript]), headers: @headers, as: :json
    assert_response :ok

    assert_equal [javascript], user.reload.mentored_tracks
    expected = {
      tracks: SerializeTracksForMentoring.(Track.where(id: javascript.id), user)
    }
    assert_equal expected.to_json, response.body
  end
end
