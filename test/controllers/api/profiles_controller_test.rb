require_relative './base_test_case'

class API::ProfilesControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_profile_path, args: 0, method: :post
  guard_incorrect_token! :api_profile_path, args: 0, method: :delete

  ##########
  # Create #
  ##########
  test "create: creates profile" do
    user = create :user
    sign_in!(user)

    post api_profile_url, params: { user: { name: "User" } }, headers: @headers, as: :json

    assert_response 200
    assert user.reload.profile
    expected = {
      links: { profile: "https://test.exercism.org/profiles/#{user.handle}?first_time=true" }
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "create: redirects to existing profile" do
    user = create :user
    create :user_profile, user: user
    sign_in!(user)

    post api_profile_url, params: { user: { name: "User" } }, headers: @headers, as: :json

    assert_response 200
    expected = {
      links: { profile: "https://test.exercism.org/profiles/#{user.handle}?first_time=true" }
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end
end
