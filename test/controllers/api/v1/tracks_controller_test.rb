require_relative '../base_test_case'

class API::V1::TracksControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_v1_track_path, args: 1

  test "show should return 404 when there is no track" do
    setup_user
    get api_v1_track_path(SecureRandom.uuid), headers: @headers, as: :json
    assert_response :not_found
    expected = {
      error: {
        type: "track_not_found",
        message: I18n.t('api.errors.track_not_found'),
        fallback_url: tracks_url
      }
    }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "show should return 200 with valid track" do
    setup_user
    track = create :track
    get api_v1_track_path(track.slug), headers: @headers, as: :json
    assert_response :ok

    expected = {
      track: {
        id: track.slug,
        language: track.title
      }
    }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end
end
