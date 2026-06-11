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
    post api_jiki_user_statuses_path, params: { exercism_ids: [1] }, as: :json
    assert_response :unauthorized
  end

  test "returns 401 with a bad token" do
    post api_jiki_user_statuses_path,
      params: { exercism_ids: [1] },
      headers: { 'Authorization' => "Bearer wrong" },
      as: :json
    assert_response :unauthorized
  end

  test "returns 401 when secret is not configured" do
    Exercism.secrets.jiki_api_key = nil

    post api_jiki_user_statuses_path,
      params: { exercism_ids: [1] },
      headers: { 'Authorization' => "Bearer #{TOKEN}" },
      as: :json
    assert_response :unauthorized
  end

  test "returns statuses for known users" do
    insider = create(:user)
    insider.data.update!(insiders_status: :active)

    lifetime = create(:user)
    lifetime.data.update!(insiders_status: :active_lifetime)

    bootcamper = create(:user)
    create(:user_bootcamp_data, user: bootcamper, enrolled_on_part_1: true)

    mentor = create(:user, bootcamp_mentor: true)

    normal = create(:user)

    post api_jiki_user_statuses_path,
      params: { exercism_ids: [insider.id, lifetime.id, bootcamper.id, mentor.id, normal.id] },
      headers: { 'Authorization' => "Bearer #{TOKEN}" },
      as: :json
    assert_response :ok

    assert_equal(
      {
        "statuses" => [
          { "exercism_id" => insider.id, "is_insider" => true, "is_bootcamp_member" => false },
          { "exercism_id" => lifetime.id, "is_insider" => true, "is_bootcamp_member" => false },
          { "exercism_id" => bootcamper.id, "is_insider" => false, "is_bootcamp_member" => true },
          { "exercism_id" => mentor.id, "is_insider" => false, "is_bootcamp_member" => true },
          { "exercism_id" => normal.id, "is_insider" => false, "is_bootcamp_member" => false }
        ]
      },
      response.parsed_body
    )
  end

  test "returns false/false for unknown ids and preserves input order" do
    user = create(:user)
    user.data.update!(insiders_status: :active)

    post api_jiki_user_statuses_path,
      params: { exercism_ids: [999_999, user.id, 888_888] },
      headers: { 'Authorization' => "Bearer #{TOKEN}" },
      as: :json
    assert_response :ok

    statuses = response.parsed_body["statuses"]
    assert_equal 999_999, statuses[0]["exercism_id"]
    refute statuses[0]["is_insider"]
    refute statuses[0]["is_bootcamp_member"]
    assert_equal user.id, statuses[1]["exercism_id"]
    assert statuses[1]["is_insider"]
    assert_equal 888_888, statuses[2]["exercism_id"]
    refute statuses[2]["is_insider"]
  end

  test "handles empty ids array" do
    post api_jiki_user_statuses_path,
      params: { exercism_ids: [] },
      headers: { 'Authorization' => "Bearer #{TOKEN}" },
      as: :json
    assert_response :ok
    assert_equal({ "statuses" => [] }, response.parsed_body)
  end
end
