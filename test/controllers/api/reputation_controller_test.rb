require_relative './base_test_case'

class API::ReputatationControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_reputation_index_path
  guard_incorrect_token! :mark_as_seen_api_reputation_index_path, method: :patch

  #########
  # INDEX #
  #########
  test "index should proxy params" do
    setup_user
    create :user_reputation_token

    User::ReputationToken::Search.expects(:call).with(
      @current_user,
      criteria: "ru",
      category: "authoring"
    ).returns(User::ReputationToken.page(1).per(10))

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
    serialized = SerializeReputationTokens.([token])
    assert_equal(
      {
        results: serialized,
        meta: {
          current_page: 1,
          total_count: 1,
          total_pages: 1
        }
      }.to_json,
      response.body
    )
  end

  ################
  # mark_as_seen #
  ################

  test "mark_as_seen should mark tokens as seen" do
    setup_user
    token_1 = create :user_reputation_token, user: @current_user
    token_2 = create :user_reputation_token, user: @current_user

    # Token we don't want to mark as seen
    token_3 = create :user_reputation_token, user: @current_user

    # A token for a different user
    token_4 = create :user_reputation_token

    patch mark_as_seen_api_reputation_index_path(
      ids: [token_1.uuid, token_2.uuid]
    ), headers: @headers, as: :json

    assert_response :success

    assert token_1.reload.seen?
    assert token_2.reload.seen?
    refute token_3.reload.seen?
    refute token_4.reload.seen?
  end
end
