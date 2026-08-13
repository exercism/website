require_relative '../base_test_case'

module API
  module Users
    class PublicControllerTest < API::BaseTestCase
      test "returns serialized user" do
        user = create :user, handle: 'iHiD', flair: :insider, reputation: 12_400
        create(:user_profile, user:)
        track = create :track, slug: 'ruby'
        create(:user_reputation_token, user:, track:)

        get api_public_user_path('iHiD'), as: :json

        assert_response :ok
        assert_equal SerializePublicUser.(user.reload).to_json, response.body
      end

      test "returns 404 for unknown user" do
        get api_public_user_path('nobody'), as: :json

        assert_response :not_found
        assert_equal "user_not_found", response.parsed_body["error"]["type"]
      end

      test "sets public cache headers" do
        create :user, handle: 'iHiD'

        get api_public_user_path('iHiD'), as: :json

        cache_control = response.headers["Cache-Control"]
        assert_includes cache_control, "public"
        assert_includes cache_control, "max-age=3600"
        assert_includes cache_control, "s-maxage=3600"
      end

      test "does not set any cookies" do
        create :user, handle: 'iHiD'

        get api_public_user_path('iHiD'), as: :json

        assert_response :ok
        assert_nil response.headers["Set-Cookie"]
      end

      test "does not set any cookies for a signed in user" do
        user = create :user, handle: 'iHiD'
        sign_in!(user)

        get api_public_user_path('iHiD'), as: :json

        assert_response :ok
        assert_nil response.headers["Set-Cookie"]
      end
    end
  end
end
