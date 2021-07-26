require_relative "../react_component_test_case"

module Profile
  class CommunitySolutionsListTest < ReactComponentTestCase
    test "component with empty concepts map rendered correctly" do
      user = create :user
      solution = create :practice_solution, :published, user: user

      component = ReactComponents::Profile::CommunitySolutionsList.new(user, {}).to_s

      assert_component component, "profile-community-solutions-list", {
        request: {
          endpoint: Exercism::Routes.api_profile_solutions_url(user),
          query: params.slice(*AssembleProfileSolutionsList.keys),
          options: { initial_data: AssembleProfileSolutionsList.(user, params) }
        },
        tracks: [
          SerializeTrackForSelect::ALL_TRACK.merge(num_solutions: 1),
          SerializeTrackForSelect.(solution.track).merge(num_solutions: 1)
        ]
      }
    end
  end
end
