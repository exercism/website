require_relative "../react_component_test_case"

class ReactComponents::Profile::ContributionsListTest < ReactComponentTestCase
  test "only the first category has initial data" do
    user = create :user
    create(:user_profile, user:)
    create(:user_code_contribution_reputation_token, user:)
    create(:user_code_review_reputation_token, user:)

    component = ReactComponents::Profile::ContributionsList.new(user).to_s

    assert_component component, "profile-contributions-list", {
      categories: [
        {
          title: "Building",
          icon: "building",
          count: 1,
          request: {
            endpoint: Exercism::Routes.building_api_profile_contributions_url(user.handle),
            options: {
              initial_data: SerializePaginatedCollection.(
                User::ReputationToken::Search.(user, category: %i[building authoring]),
                serializer: SerializeUserReputationTokens
              )
            }
          }
        },
        {
          title: "Maintaining",
          icon: "maintaining",
          count: 1,
          request: {
            endpoint: Exercism::Routes.maintaining_api_profile_contributions_url(user.handle),
            options: {}
          }
        }
      ]
    }
  end
end
