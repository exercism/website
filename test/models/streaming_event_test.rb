require "test_helper"

class StreamingEventTest < ActiveSupport::TestCase
  test "live" do
    # Sanity check: past event
    create :streaming_event, :past
    assert_empty StreamingEvent.live

    # Sanity check: future event is ignored
    create :streaming_event
    assert_empty StreamingEvent.live

    live_event = create :streaming_event, :live
    assert_equal [live_event], StreamingEvent.live
  end

  test "scheduled" do
    # Sanity check: past event
    create :streaming_event, :past
    assert_empty StreamingEvent.next_5

    # Sanity check: live event is ignored
    create :streaming_event, :live
    assert_empty StreamingEvent.next_5

    scheduled_events = create_list :streaming_event, 6, starts_at: Time.current + 3.hours
    assert_equal scheduled_events.take(5), StreamingEvent.next_5
  end

  test "featured" do
    # Sanity check: past event
    create :streaming_event, :past
    assert_nil StreamingEvent.next_featured

    # Sanity check: live event is ignored
    create :streaming_event, :live
    assert_nil StreamingEvent.next_featured

    # Sanity check: scheduled event that is not featured is ignored
    create :streaming_event, featured: false
    assert_nil StreamingEvent.next_featured

    featured_event = create :streaming_event, featured: true, starts_at: Time.current + 3.hours
    assert_equal featured_event, StreamingEvent.next_featured

    # Sanity check: scheduled event that is not the first featured event is ignored
    create :streaming_event, featured: true, starts_at: Time.current + 6.hours
    assert_equal featured_event, StreamingEvent.next_featured
  end
end
