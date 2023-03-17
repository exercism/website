require "test_helper"

class StreamingEventTest < ActiveSupport::TestCase
  test "live" do
    # Sanity check: past event
    create :streaming_event, starts_at: Time.current - 3.days, ends_at: Time.current - 2.days
    assert_empty StreamingEvent.live
    assert_nil StreamingEvent.current_live

    # Sanity check: future event is ignored
    create :streaming_event, starts_at: Time.current + 3.days, ends_at: Time.current + 4.days
    assert_empty StreamingEvent.live
    assert_nil StreamingEvent.current_live

    live_event = create :streaming_event, starts_at: Time.current.utc - 2.hours, ends_at: Time.current.utc + 2.hours
    assert_equal [live_event], StreamingEvent.live
    assert_equal live_event, StreamingEvent.current_live
  end

  test "scheduled" do
    # Sanity check: past event
    create :streaming_event, starts_at: Time.current - 3.days, ends_at: Time.current - 2.days
    assert_empty StreamingEvent.next_5

    # Sanity check: live event is ignored
    create :streaming_event, starts_at: Time.current - 2.hours, ends_at: Time.current + 2.hours
    assert_empty StreamingEvent.next_5

    scheduled_events = create_list(:streaming_event, 6, starts_at: Time.current.utc + 3.hours, ends_at: Time.current.utc + 5.hours)
    assert_equal scheduled_events.take(5), StreamingEvent.next_5
  end

  test "featured" do
    # Sanity check: past event
    create :streaming_event, starts_at: Time.current - 3.days, ends_at: Time.current - 2.days
    assert_nil StreamingEvent.next_featured

    # Sanity check: live event is ignored
    create :streaming_event, starts_at: Time.current - 2.hours, ends_at: Time.current + 2.hours
    assert_nil StreamingEvent.next_featured

    # Sanity check: scheduled event that is not featured is ignored
    create(:streaming_event, featured: false, starts_at: Time.current.utc + 3.hours, ends_at: Time.current.utc + 5.hours)
    assert_nil StreamingEvent.next_featured

    create(:streaming_event, featured: false, starts_at: Time.current.utc + 3.hours, ends_at: Time.current.utc + 5.hours)
    assert_nil StreamingEvent.next_featured

    featured_event = create(:streaming_event, featured: true, starts_at: Time.current.utc + 3.hours,
      ends_at: Time.current.utc + 5.hours)
    assert_equal featured_event, StreamingEvent.next_featured

    # Sanity check: scheduled event that is not the first featured event is ignored
    create(:streaming_event, featured: true, starts_at: Time.current.utc + 6.hours, ends_at: Time.current.utc + 7.hours)
    assert_equal featured_event, StreamingEvent.next_featured
  end
end
