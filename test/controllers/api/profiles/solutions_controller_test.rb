require_relative '../base_test_case'

class API::Profiles::SolutionsControllerTest < API::BaseTestCase
  ###
  # Index
  ###
  test "index 404s without user" do
    setup_user

    get api_profile_solutions_path("some-random-user"), headers: @headers, as: :json

    assert_response :not_found
    expected = { error: {
      type: "profile_not_found",
      message: I18n.t('api.errors.profile_not_found')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "index 404s when user doesn't have a profile" do
    setup_user
    user = create :user

    get api_profile_solutions_path(user), headers: @headers, as: :json

    assert_response :not_found
    expected = { error: {
      type: "profile_not_found",
      message: I18n.t('api.errors.profile_not_found')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "index proxies correctly" do
    setup_user

    profile_user = create(:user_profile).user
    page = 15
    track_slug = "ruby"

    Solution::SearchUserSolutions.expects(:call).with(
      profile_user,
      status: :published,
      criteria: "Foobar",
      track_slug:,
      order: "recent",
      page:
    ).returns(Solution.page(1).per(1))

    get api_profile_solutions_path(profile_user), params: {
      page:,
      criteria: "Foobar",
      order: "recent",
      track_slug:
    }, headers: @headers, as: :json
  end

  test "index retrieves solutions" do
    Solution::SearchUserSolutions::Fallback.expects(:call).never

    setup_user

    profile_user = create(:user_profile).user
    5.times { |i| create :practice_solution, :published, user: profile_user, num_stars: i }

    Solution.find_each { |solution| create :iteration, submission: create(:submission, solution:) }

    wait_for_opensearch_to_be_synced

    get api_profile_solutions_path(profile_user), headers: @headers, as: :json
    assert_response :ok

    expected = SerializePaginatedCollection.(
      Solution.order(num_stars: :desc).page(1),
      serializer: SerializeCommunitySolutions,
      meta: {
        unscoped_total: 5
      }
    ).to_json

    assert_equal expected, response.body
  end
end
