require_relative './base_test_case'

class API::ReputatationControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_reputation_index_path
  guard_incorrect_token! :mark_as_seen_api_reputation_path, args: 1, method: :patch

  #########
  # INDEX #
  #########
  test "index should proxy params" do
    setup_user
    create :user_code_contribution_reputation_token

    User::ReputationToken::Search.expects(:call).with(
      @current_user,
      criteria: "ru",
      category: "authoring",
      order: "unseen_first",
      page: "5",
      per: "20"
    ).returns(User::ReputationToken.page(1).per(10))

    get api_reputation_index_path(
      criteria: "ru",
      category: "authoring",
      order: "unseen_first",
      page: 5,
      per_page: 20
    ), headers: @headers, as: :json

    assert_response :ok
  end

  test "index should search and return reputation" do
    setup_user
    ruby = create :track, title: "Ruby"
    ruby_bob = create :concept_exercise, track: ruby, title: "Bob"
    create :user_code_contribution_reputation_token,
      user: @current_user,
      exercise: ruby_bob,
      track: ruby

    params = {
      criteria: "ru",
      category: "building"
    }

    get api_reputation_index_path(params), headers: @headers, as: :json

    assert_response :ok
    assert_equal(
      AssembleReputationTokens.(@current_user.reload, params).with_indifferent_access,
      JSON.parse(response.body).with_indifferent_access
    )
  end

  ###################
  # Marking as seen #
  ###################

  test "mark_as_seen should mark tokens as seen" do
    setup_user
    token_1 = create :user_code_contribution_reputation_token, user: @current_user

    # Token we don't want to mark as seen
    token_2 = create :user_code_contribution_reputation_token, user: @current_user

    # A token for a different user
    token_3 = create :user_code_contribution_reputation_token

    patch mark_as_seen_api_reputation_path(token_1.uuid), headers: @headers, as: :json

    assert_response :ok

    assert token_1.reload.seen?
    refute token_2.reload.seen?
    refute token_3.reload.seen?
  end

  test "mark_as_seen is rate limited" do
    setup_user

    beginning_of_minute = Time.current.beginning_of_minute
    travel_to beginning_of_minute

    20.times do
      token = create :user_code_contribution_reputation_token, user: @current_user
      patch mark_as_seen_api_reputation_path(token.uuid), headers: @headers, as: :json
      assert_response :ok
    end

    token = create :user_code_contribution_reputation_token, user: @current_user
    patch mark_as_seen_api_reputation_path(token.uuid), headers: @headers, as: :json
    assert_response :too_many_requests

    # Verify that the rate limit resets every minute
    travel_to beginning_of_minute + 1.minute

    token = create :user_code_contribution_reputation_token, user: @current_user
    patch mark_as_seen_api_reputation_path(token.uuid), headers: @headers, as: :json
    assert_response :ok
  end

  test "mark_all_as_seen proxies" do
    user = create :user
    setup_user(user)

    User::ReputationToken::MarkAllAsSeen.expects(:call).with(user)

    patch mark_all_as_seen_api_reputation_index_path, headers: @headers, as: :json
    assert_response :ok

    assert_equal(
      AssembleReputationTokens.(@current_user.reload, {}).with_indifferent_access,
      JSON.parse(response.body).with_indifferent_access
    )
  end
end
