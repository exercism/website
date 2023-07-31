require_relative "../react_component_test_case"

class ReactComponents::Mentoring::InboxTest < ReactComponentTestCase
  test "mentoring inbox rendered correctly" do
    component = ReactComponents::Mentoring::Inbox.new({
      criteria: "Ruby"
    })

    assert_component component,
      "mentoring-inbox",
      {
        discussions_request: {
          endpoint: Exercism::Routes.api_mentoring_discussions_path(sideload: [:all_discussion_counts]),
          query: { status: "awaiting_mentor", criteria: "Ruby", page: 1 },
          options: { stale_time: 0 }
        },
        tracks_request: {
          endpoint: Exercism::Routes.tracks_api_mentoring_discussions_path,
          query: { status: "awaiting_mentor" },
          options: { stale_time: 0 }
        },
        sort_options: [
          { value: 'recent', label: 'Sort by recent first' },
          { value: 'oldest', label: 'Sort by oldest first' },
          { value: 'exercise', label: 'Sort by exercise' },
          { value: 'student', label: 'Sort by student' }
        ],
        links: {
          queue: Exercism::Routes.mentoring_queue_path
        }
      }
  end
end
