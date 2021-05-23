require_relative "../react_component_test_case"

class MentoringInboxTest < ReactComponentTestCase
  test "mentoring inbox rendered correctly" do
    component = ReactComponents::Mentoring::Inbox.new(
      criteria: "Ruby"
    )

    assert_component component,
      "mentoring-inbox",
      {
        discussions_request: {
          endpoint: Exercism::Routes.api_mentoring_discussions_path(sideload: [:all_discussion_counts]),
          query: { status: "awaiting_mentor", criteria: "Ruby" }
        },
        tracks_request: {
          endpoint: Exercism::Routes.tracks_api_mentoring_discussions_path,
          query: { status: "awaiting_mentor" }
        },
        sort_options: [
          { value: '', label: 'Sort by oldest first' },
          { value: 'recent', label: 'Sort by recent first' },
          { value: 'exercise', label: 'Sort by exercise' },
          { value: 'student', label: 'Sort by student' }
        ]
      }
  end
end
