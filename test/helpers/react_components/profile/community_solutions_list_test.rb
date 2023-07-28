require_relative "../react_component_test_case"

class ReactComponents::Profile::CommunitySolutionsListTest < ReactComponentTestCase
  test "component with empty concepts map rendered correctly" do
    user = create :user
    create(:user_profile, user:)
    solution = create(:practice_solution, :published, user:)

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

  test "tracks are sorted by title" do
    track_1 = create :track, slug: 'csharp', title: 'C#'
    track_2 = create :track, slug: 'ruby', title: 'Ruby'
    track_3 = create :track, slug: 'awk', title: 'AWK'

    user = create :user
    create(:user_profile, user:)
    create :practice_solution, :published, user:, track: track_1
    create :practice_solution, :published, user:, track: track_2
    create :practice_solution, :published, user:, track: track_3

    component = ReactComponents::Profile::CommunitySolutionsList.new(user, {}).to_s

    assert_component component, "profile-community-solutions-list", {
      request: {
        endpoint: Exercism::Routes.api_profile_solutions_url(user),
        query: params.slice(*AssembleProfileSolutionsList.keys),
        options: { initial_data: AssembleProfileSolutionsList.(user, params) }
      },
      tracks: [
        SerializeTrackForSelect::ALL_TRACK.merge(num_solutions: 3),
        SerializeTrackForSelect.(track_3).merge(num_solutions: 1),
        SerializeTrackForSelect.(track_1).merge(num_solutions: 1),
        SerializeTrackForSelect.(track_2).merge(num_solutions: 1)
      ]
    }
  end
end
