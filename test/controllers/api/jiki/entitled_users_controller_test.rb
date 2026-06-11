require_relative '../base_test_case'

class API::Jiki::EntitledUsersControllerTest < API::BaseTestCase
  TOKEN = "test-jiki-api-key".freeze

  setup do
    @original_jiki_api_key = Exercism.secrets.jiki_api_key
    Exercism.secrets.jiki_api_key = TOKEN
  end

  teardown do
    Exercism.secrets.jiki_api_key = @original_jiki_api_key
  end

  test "returns 401 without a token" do
    get api_jiki_entitled_users_path, as: :json
    assert_response :unauthorized
  end

  test "returns 401 with a bad token" do
    get api_jiki_entitled_users_path,
      headers: { 'Authorization' => "Bearer wrong" },
      as: :json
    assert_response :unauthorized
  end

  test "returns insider and bootcamp ids" do
    insider = create(:user)
    insider.data.update!(insiders_status: :active)

    lifetime = create(:user)
    lifetime.data.update!(insiders_status: :active_lifetime)

    bootcamper = create(:user)
    create(:user_bootcamp_data, user: bootcamper, enrolled_on_part_1: true)

    mentor = create(:user, bootcamp_mentor: true)

    create(:user) # normal user, no entitlements

    get api_jiki_entitled_users_path,
      headers: { 'Authorization' => "Bearer #{TOKEN}" },
      as: :json
    assert_response :ok

    body = response.parsed_body
    assert_equal [insider.id, lifetime.id].sort, body["insider_ids"].sort
    assert_equal [bootcamper.id, mentor.id].sort, body["bootcamp_member_ids"].sort
  end

  test "returns empty arrays when no entitled users" do
    create(:user)

    get api_jiki_entitled_users_path,
      headers: { 'Authorization' => "Bearer #{TOKEN}" },
      as: :json
    assert_response :ok

    assert_equal({ "insider_ids" => [], "bootcamp_member_ids" => [] }, response.parsed_body)
  end
end
