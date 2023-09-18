require_relative './base_test_case'

module API
  class StreamingEventsControllerTest < API::BaseTestCase
    test "index - return scheduled streaming events by default" do
      setup_user
      live_event = create :streaming_event, :live
      past_event = create :streaming_event, :past
      scheduled_1 = create :streaming_event, starts_at: Time.current + 3.hours
      scheduled_2 = create :streaming_event, starts_at: Time.current + 2.hours

      get api_streaming_events_path, headers: @headers, as: :json
      assert_response :ok
      assert_includes response.body, scheduled_1.title
      assert_includes response.body, scheduled_2.title
      refute_includes response.body, live_event.title
      refute_includes response.body, past_event.title
    end

    test "index - return live streaming events" do
      setup_user
      live_event = create :streaming_event, :live
      past_event = create :streaming_event, :past
      scheduled_1 = create :streaming_event, starts_at: Time.current + 3.hours
      scheduled_2 = create :streaming_event, starts_at: Time.current + 2.hours

      get api_streaming_events_path(live: true), headers: @headers, as: :json
      assert_response :ok
      refute_includes response.body, past_event.title
      refute_includes response.body, scheduled_1.title
      refute_includes response.body, scheduled_2.title
      assert_includes response.body, live_event.title
    end

    test "index - paginates" do
      AssembleStreamingEvents.stubs(:events_per_page).returns(1)

      setup_user
      event_1 = create :streaming_event
      event_2 = create :streaming_event

      get api_streaming_events_path(page: 1), headers: @headers, as: :json
      assert_response :ok
      assert_includes response.body, event_1.title
      refute_includes response.body, event_2.title

      get api_streaming_events_path(page: 2), headers: @headers, as: :json
      assert_response :ok
      refute_includes response.body, event_1.title
      assert_includes response.body, event_2.title
    end
  end
end
