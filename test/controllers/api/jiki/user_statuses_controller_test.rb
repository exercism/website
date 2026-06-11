require_relative '../base_test_case'

class API::Jiki::UserStatusesControllerTest < API::BaseTestCase
  TOKEN = "test-jiki-api-key".freeze

  setup do
    @original_jiki_api_key = Exercism.secrets.jiki_api_key
    Exercism.secrets.jiki_api_key = TOKEN
  end

  teardown do
    Exercism.secrets.jiki_api_key = @original_jiki_api_key
  end

  test "returns 401 without a token" do
    user = create(:user)
    get api_jiki_user_status_path(exercism_id: user.id), as: :json
    assert_response :unauthorized
  end

  test "returns 401 with a bad token" do
    user = create(:user)
    get api_jiki_user_status_path(exercism_id: user.id),
      headers: { 'Authorization' => "Bearer wrong" },
      as: :json
    assert_response :unauthorized
  end

  test "returns status for insider" do
    user = create(:user)
    user.data.update!(insiders_status: :active)

    get api_jiki_user_status_path(exercism_id: user.id),
      headers: { 'Authorization' => "Bearer #{TOKEN}" },
      as: :json
    assert_response :ok
    assert_equal({ "is_insider" => true, "is_bootcamp_member" => false }, response.parsed_body)
  end

  test "returns status for bootcamp member" do
    user = create(:user)
    create(:user_bootcamp_data, user:, enrolled_on_part_1: true)

    get api_jiki_user_status_path(exercism_id: user.id),
      headers: { 'Authorization' => "Bearer #{TOKEN}" },
      as: :json
    assert_response :ok
    assert_equal({ "is_insider" => false, "is_bootcamp_member" => true }, response.parsed_body)
  end

  test "returns 200 with false/false for unknown id" do
    get api_jiki_user_status_path(exercism_id: 999_999),
      headers: { 'Authorization' => "Bearer #{TOKEN}" },
      as: :json
    assert_response :ok
    assert_equal({ "is_insider" => false, "is_bootcamp_member" => false }, response.parsed_body)
  end
end
