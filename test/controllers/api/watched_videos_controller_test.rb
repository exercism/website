require_relative './base_test_case'

module API
  class WatchedVideosControllerTest < API::BaseTestCase
    guard_incorrect_token! :api_watched_videos_path, args: 0, method: :post

    ##########
    # Create #
    ##########
    test "creates record" do
      user = create :user
      setup_user(user)

      id = SecureRandom.uuid

      # Sanity
      refute user.watched_video?(:youtube, id)

      post api_watched_videos_path(
        video_provider: :youtube,
        video_id: id
      ), headers: @headers, as: :json

      assert_response :ok
      assert_empty(JSON.parse(response.body))

      assert user.watched_video?(:youtube, id)
    end
  end
end
