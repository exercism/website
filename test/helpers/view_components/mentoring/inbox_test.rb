require_relative "../view_component_test_case"

class MentoringInboxTest < ViewComponentTestCase
  test "mentoring inbox rendered correctly" do
    conversations_request = { endpoint: "conversations-endpoint" }
    tracks_request = { endpoint: "tracks-endpoint" }

    component = ViewComponents::Mentoring::Inbox.new(
      conversations_request, tracks_request
    ).to_s

    assert_component_equal(
      component,
      {
        id: "mentoring-inbox",
        props: {
          conversations_request: { endpoint: "conversations-endpoint" },
          tracks_request: { endpoint: "tracks-endpoint" },
          sort_options: ViewComponents::Mentoring::Inbox::SORT_OPTIONS
        }
      }
    )
  end
end
