require "test_helper"

class Admin::StreamingEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @streaming_event = create :streaming_event

    sign_in!(create(:user, :admin))
  end

  test "should get index" do
    get admin_streaming_events_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_streaming_event_url
    assert_response :success
  end

  test "should create admin_streaming_event" do
    assert_difference("StreamingEvent.count") do
      post admin_streaming_events_url,
        params: { streaming_event: {
          description: @streaming_event.description,
          ends_at: @streaming_event.ends_at,
          featured: @streaming_event.featured,
          starts_at: @streaming_event.starts_at,
          thumbnail_url: @streaming_event.thumbnail_url,
          title: @streaming_event.title,
          youtube_id: @streaming_event.youtube_id
        } }
    end

    assert_redirected_to admin_streaming_event_url(StreamingEvent.last)
  end

  test "should show admin_streaming_event" do
    get admin_streaming_event_url(@streaming_event)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_streaming_event_url(@streaming_event)
    assert_response :success
  end

  test "should update admin_streaming_event" do
    patch admin_streaming_event_url(@streaming_event),
      params: { streaming_event: {
        description: @streaming_event.description,
        ends_at: @streaming_event.ends_at,
        featured: @streaming_event.featured,
        starts_at: @streaming_event.starts_at,
        thumbnail_url: @streaming_event.thumbnail_url,
        title: @streaming_event.title,
        youtube_id: @streaming_event.youtube_id
      } }
    assert_redirected_to admin_streaming_event_url(@streaming_event)
  end

  test "should destroy admin_streaming_event" do
    assert_difference("StreamingEvent.count", -1) do
      delete admin_streaming_event_url(@streaming_event)
    end

    assert_redirected_to admin_streaming_events_url
  end
end
