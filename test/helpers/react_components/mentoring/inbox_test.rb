require_relative "../react_component_test_case"

class MentoringInboxTest < ReactComponentTestCase
  test "mentoring inbox rendered correctly" do
    component = ReactComponents::Mentoring::Inbox.new

    assert_component component,
      "mentoring-inbox",
      {
        discussions_request: { endpoint: Exercism::Routes.api_mentoring_discussions_path },
        tracks_request: { endpoint: Exercism::Routes.tracks_api_mentoring_discussions_path },
        sort_options: [
          { value: 'recent', label: 'Sort by Most Recent' },
          { value: 'exercise', label: 'Sort by Exercise' },
          { value: 'student', label: 'Sort by Student' }
        ]
      }
  end
end
