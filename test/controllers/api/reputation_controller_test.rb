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
      page: "5",
      per: "20"
    ).returns(User::ReputationToken.page(1).per(10))

    get api_reputation_index_path(
      criteria: "ru",
      category: "authoring",
      page: 5,
      per: 20
    ), headers: @headers, as: :json

    assert_response :success
  end

  test "index should search and return reputation" do
    setup_user
    ruby = create :track, title: "Ruby"
    ruby_bob = create :concept_exercise, track: ruby, title: "Bob"
    token = create :user_code_contribution_reputation_token,
      user: @current_user,
      exercise: ruby_bob,
      track: ruby

    get api_reputation_index_path(
      criteria: "ru",
      category: "building"
    ), headers: @headers, as: :json

    assert_response :success
    assert_equal(
      {
        results: [
          token.rendering_data.merge(links: {
                                       mark_as_seen: Exercism::Routes.mark_as_seen_api_reputation_url(token.uuid)
                                     })
        ],
        meta: {
          current_page: 1,
          total_count: 1,
          total_pages: 1,
          links: {
            tokens: Exercism::Routes.reputation_journey_url
          },
          total_reputation: @current_user.reload.reputation
        }
      }.with_indifferent_access,
      JSON.parse(response.body).with_indifferent_access
    )
  end

  ################
  # mark_as_seen #
  ################

  test "mark_as_seen should mark tokens as seen" do
    setup_user
    token_1 = create :user_code_contribution_reputation_token, user: @current_user

    # Token we don't want to mark as seen
    token_2 = create :user_code_contribution_reputation_token, user: @current_user

    # A token for a different user
    token_3 = create :user_code_contribution_reputation_token

    patch mark_as_seen_api_reputation_path(token_1.uuid), headers: @headers, as: :json

    assert_response :success

    assert token_1.reload.seen?
    refute token_2.reload.seen?
    refute token_3.reload.seen?
  end
end
