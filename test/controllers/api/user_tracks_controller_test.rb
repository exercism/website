require_relative './base_test_case'

class API::UserTracksControllerTest < API::BaseTestCase
  guard_incorrect_token! :activate_learning_mode_api_track_path, args: 1
  guard_incorrect_token! :activate_practice_mode_api_track_path, args: 1
  guard_incorrect_token! :reset_api_track_path, args: 1
  guard_incorrect_token! :leave_api_track_path, args: 1

  ##########################
  # Activate Learning Mode #
  ##########################
  test "activate_learning_mode" do
    setup_user
    user_track = create :user_track, user: @current_user, practice_mode: true
    assert user_track.reload.practice_mode # Sanity

    patch activate_learning_mode_api_track_path(user_track.track), headers: @headers, as: :json

    assert_response :ok
    refute user_track.reload.practice_mode
  end

  ##########################
  # Activate Practice Mode #
  ##########################
  test "activate_practice_mode" do
    setup_user
    user_track = create :user_track, user: @current_user, practice_mode: false
    refute user_track.reload.practice_mode # Sanity

    patch activate_practice_mode_api_track_path(user_track.track), headers: @headers, as: :json

    assert_response :ok
    assert user_track.reload.practice_mode
  end

  ###############
  # Reset Track #
  ###############
  test "reset resets" do
    setup_user
    user_track = create :user_track, user: @current_user, practice_mode: false

    UserTrack::Reset.expects(:call).with(user_track)

    patch reset_api_track_path(user_track.track), headers: @headers, as: :json

    assert_response :ok
  end

  ###############
  # Leave Track #
  ###############
  test "leave resets if requested" do
    setup_user
    user_track = create :user_track, user: @current_user, practice_mode: false

    UserTrack::Reset.expects(:call).with(user_track)

    patch leave_api_track_path(user_track.track), headers: @headers, params: { reset: true }, as: :json

    assert_response :ok
    assert_raises ActiveRecord::RecordNotFound do
      user_track.reload
    end
  end

  test "leave does not reset unless requested" do
    setup_user
    user_track = create :user_track, user: @current_user, practice_mode: false

    UserTrack::Reset.expects(:call).never

    patch leave_api_track_path(user_track.track), headers: @headers, params: { reset: false }, as: :json

    assert_response :ok
    assert_raises ActiveRecord::RecordNotFound do
      user_track.reload
    end
  end
end
