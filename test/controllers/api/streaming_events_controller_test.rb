require_relative './base_test_case'

module API
  class StreamingEventsControllerTest < API::BaseTestCase
    test "index - return live streaming events by default" do
      setup_user
      event_1 = create :streaming_event, :random, starts_at: Time.current - 3.hours, ends_at: Time.current + 3.hours
      event_2 = create :streaming_event, :random, starts_at: Time.current - 2.hours, ends_at: Time.current + 4.hours
      event_3 = create :streaming_event, :random, starts_at: Time.current - 6.days, ends_at: Time.current - 5.days

      get api_streaming_events_path, headers: @headers, as: :json
      assert_response :ok
      assert_includes response.body, event_1.title
      assert_includes response.body, event_2.title
      refute_includes response.body, event_3.title
    end

    test "index - return scheduled streaming events" do
      setup_user
      event_1 = create :streaming_event, :random, starts_at: Time.current - 3.hours, ends_at: Time.current + 3.hours
      event_2 = create :streaming_event, :random, starts_at: Time.current + 2.hours, ends_at: Time.current + 4.hours
      event_3 = create :streaming_event, :random, starts_at: Time.current + 6.days, ends_at: Time.current + 7.days

      get api_streaming_events_path(scheduled: true), headers: @headers, as: :json
      assert_response :ok
      refute_includes response.body, event_1.title
      assert_includes response.body, event_2.title
      assert_includes response.body, event_3.title
    end

    test "index - paginates" do
      AssembleStreamingEvents.stubs(:events_per_page).returns(1)

      setup_user
      event_1 = create :streaming_event, :random, starts_at: Time.current - 4.hours, ends_at: Time.current + 3.hours
      event_2 = create :streaming_event, :random, starts_at: Time.current - 3.hours, ends_at: Time.current + 4.hours

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
