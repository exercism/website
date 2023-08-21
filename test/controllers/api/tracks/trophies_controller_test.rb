require_relative '../base_test_case'

class API::Tracks::TrophiesControllerTest < API::BaseTestCase
  # guard_incorrect_token! :reveal_api_track_trophy_path, args: 2, method: :patch

  ##########
  # Reveal #
  ##########
  test "reveal: should 200 and reveal trophy" do
    acquired_trophy = create(:user_track_acquired_trophy, revealed: false)
    track_slug = acquired_trophy.track.slug
    uuid = acquired_trophy.uuid

    sign_in!(acquired_trophy.user)

    patch reveal_api_track_trophy_url(track_slug, uuid), headers: @headers, as: :json

    assert_response :ok
    assert acquired_trophy.reload.revealed
  end

  test "reveal: should 404 if track could not be found" do
    acquired_trophy = create(:user_track_acquired_trophy, revealed: false)
    track_slug = "unknown track"
    uuid = acquired_trophy.uuid

    sign_in!(acquired_trophy.user)

    patch reveal_api_track_trophy_url(track_slug, uuid), headers: @headers, as: :json

    assert_response :not_found
    expected = {
      error: {
        type: "track_not_found",
        message: I18n.t('api.errors.track_not_found'),
        fallback_url: "http://test.exercism.org/tracks"
      }
    }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "reveal: should 404 if trophy could not be found" do
    acquired_trophy = create(:user_track_acquired_trophy, revealed: false)
    track_slug = acquired_trophy.track.slug
    uuid = "unknown uuid"

    sign_in!(acquired_trophy.user)

    patch reveal_api_track_trophy_url(track_slug, uuid), headers: @headers, as: :json

    assert_response :not_found
    expected = {
      error: {
        type: "trophy_not_found",
        message: I18n.t('api.errors.trophy_not_found')
      }
    }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "reveal: should 403 if trophy has different user" do
    user = create :user
    other_user = create :user
    acquired_trophy = create(:user_track_acquired_trophy, user: other_user, revealed: false)
    track_slug = acquired_trophy.track.slug
    uuid = acquired_trophy.uuid

    sign_in!(user)

    patch reveal_api_track_trophy_url(track_slug, uuid), headers: @headers, as: :json

    assert_response :forbidden
    expected = {
      error: {
        type: "trophy_not_accessible",
        message: I18n.t('api.errors.trophy_not_accessible')
      }
    }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "reveal: should 403 if trophy has different track" do
    track = create :track, slug: 'ruby'
    other_track = create :track, slug: 'kotlin'
    acquired_trophy = create(:user_track_acquired_trophy, track:, revealed: false)
    track_slug = other_track.slug
    uuid = acquired_trophy.uuid

    sign_in!(acquired_trophy.user)

    patch reveal_api_track_trophy_url(track_slug, uuid), headers: @headers, as: :json

    assert_response :forbidden
    expected = {
      error: {
        type: "trophy_not_accessible",
        message: I18n.t('api.errors.trophy_not_accessible')
      }
    }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end
end
