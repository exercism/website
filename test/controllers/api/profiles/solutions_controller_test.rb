require_relative '../base_test_case'

class API::Profiles::SolutionsControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_profile_solutions_path, args: 1

  ###
  # Index
  ###
  test "index proxies correctly" do
    setup_user

    profile_user = create(:user_profile).user
    page = 15
    track_slug = "ruby"

    Solution::SearchUserSolutions.expects(:call).with(
      profile_user,
      status: :published,
      criteria: "Foobar",
      track_slug: track_slug,
      order: "recent",
      page: page
    ).returns(Solution.page(1).per(1))

    get api_profile_solutions_path(profile_user), params: {
      page: page,
      criteria: "Foobar",
      order: "recent",
      track_slug: track_slug
    }, headers: @headers, as: :json
  end

  test "index retrieves solutions" do
    setup_user

    profile_user = create(:user_profile).user
    5.times { create :practice_solution, :published, user: profile_user }

    Solution.find_each { |solution| create :iteration, submission: create(:submission, solution: solution) }

    get api_profile_solutions_path(profile_user), headers: @headers, as: :json
    assert_response 200

    expected = SerializePaginatedCollection.(
      Solution.order(id: :desc).page(1),
      serializer: SerializeCommunitySolutions
    ).to_json

    assert_equal expected, response.body
  end
end
