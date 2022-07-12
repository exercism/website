require_relative '../base_test_case'

class API::Profiles::MentorTestimonialsControllerTest < API::BaseTestCase
  ###
  # Guards
  ###
  %i[building maintaining authoring].each do |action|
    test "#{action} 404s without user" do
      setup_user

      get send("#{action}_api_profile_contributions_path", "some-random-user"), headers: @headers, as: :json

      assert_response :not_found
      expected = { error: {
        type: "profile_not_found",
        message: I18n.t('api.errors.profile_not_found')
      } }
      actual = JSON.parse(response.body, symbolize_names: true)
      assert_equal expected, actual
    end

    test "#{action} 404s when user doesn't have a profile" do
      setup_user
      user = create :user

      get send("#{action}_api_profile_contributions_path", user), headers: @headers, as: :json

      assert_response :not_found
      expected = { error: {
        type: "profile_not_found",
        message: I18n.t('api.errors.profile_not_found')
      } }
      actual = JSON.parse(response.body, symbolize_names: true)
      assert_equal expected, actual
    end
  end

  ###
  # Building
  ###
  test "building returns correct tokens" do
    setup_user

    profile_user = create(:user_profile).user
    contribution = create :user_code_contribution_reputation_token, user: profile_user
    contribute = create :user_exercise_contribution_reputation_token, user: profile_user
    author = create :user_exercise_author_reputation_token, user: profile_user
    merge = create :user_code_merge_reputation_token, user: profile_user
    review = create :user_code_review_reputation_token, user: profile_user

    get building_api_profile_contributions_path(profile_user), headers: @headers, as: :json
    assert_response :ok

    expected = SerializePaginatedCollection.(
      User::ReputationToken::Search.(profile_user, category: %i[building authoring]),
      serializer: SerializeUserReputationTokens
    ).to_json

    assert_includes expected, contribution.uuid
    assert_includes expected, contribute.uuid
    assert_includes expected, author.uuid
    refute_includes expected, merge.uuid
    refute_includes expected, review.uuid

    assert_equal expected, response.body
  end

  ###
  # Maintaining
  ###
  test "maintaining returns correct tokens" do
    setup_user

    profile_user = create(:user_profile).user

    merge = create :user_code_merge_reputation_token, user: profile_user
    review = create :user_code_review_reputation_token, user: profile_user
    contribution = create :user_code_contribution_reputation_token, user: profile_user
    contribute = create :user_exercise_contribution_reputation_token, user: profile_user
    author = create :user_exercise_author_reputation_token, user: profile_user

    get maintaining_api_profile_contributions_path(profile_user), headers: @headers, as: :json
    assert_response :ok

    expected = SerializePaginatedCollection.(
      User::ReputationToken::Search.(profile_user, category: :maintaining),
      serializer: SerializeUserReputationTokens
    ).to_json

    refute_includes expected, contribution.uuid
    refute_includes expected, contribute.uuid
    refute_includes expected, author.uuid
    assert_includes expected, merge.uuid
    assert_includes expected, review.uuid

    assert_equal expected, response.body
  end

  ###
  # Authoring
  ###
  test "authoring returns correct exercises" do
    setup_user

    profile_user = create(:user_profile).user

    exercise_1 = create :practice_exercise
    exercise_2 = create :concept_exercise
    exercise_3 = create :practice_exercise
    create :concept_exercise

    exercise_1.authors << profile_user
    exercise_2.contributors << profile_user
    exercise_3.authors << create(:user)

    get authoring_api_profile_contributions_path(profile_user), headers: @headers, as: :json
    assert_response :ok

    expected = SerializePaginatedCollection.(
      Exercise.
        where(id: [exercise_1, exercise_2].map(&:id)).
        order(id: :desc).
        page(1).per(20),
      serializer: SerializeExerciseAuthorships
    ).to_json

    assert_equal expected, response.body
  end
end
