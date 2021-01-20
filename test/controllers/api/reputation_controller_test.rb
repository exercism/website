require_relative './base_test_case'

class API::ReputatationControllerTest < API::BaseTestCase
  #########
  # INDEX #
  #########
  test "index should return 401 with incorrect token" do
    get api_reputation_index_path, as: :json
    assert_response 401
    expected = { error: {
      type: "invalid_auth_token",
      message: I18n.t('api.errors.invalid_auth_token')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "index should proxy params" do
    setup_user
    token = create :user_reputation_token

    User::ReputationToken::Search.expects(:call).with(
      @current_user,
      criteria: "ru",
      category: "authoring"
    ).returns([token])

    get api_reputation_index_path(
      criteria: "ru",
      category: "authoring"
    ), headers: @headers, as: :json

    assert_response :success
  end

  test "index should search and return reputation" do
    setup_user
    ruby = create :track, title: "Ruby"
    ruby_bob = create :concept_exercise, track: ruby, title: "Bob"
    token = create :user_reputation_token,
      user: @current_user,
      category: :building,
      exercise: ruby_bob,
      track: ruby

    get api_reputation_index_path(
      criteria: "ru",
      category: "building"
    ), headers: @headers, as: :json

    assert_response :success
    serializer = SerializeReputationTokens.([token])
    assert_equal serializer.to_json, response.body
  end
end
