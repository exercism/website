require "test_helper"

class AssembleStreamingEventsTest < ActiveSupport::TestCase
  test "returns maximum of 20 elements" do
    create_list(:streaming_event, 25)
    actual = AssembleStreamingEvents.({})
    assert_equal 20, actual[:results].size
  end

  test "results are sorted by start date" do
    event_1 = create :streaming_event, starts_at: Time.current + 3.hours
    event_2 = create :streaming_event, starts_at: Time.current + 2.hours
    event_3 = create :streaming_event, starts_at: Time.current + 4.hours

    actual = AssembleStreamingEvents.({})
    assert_equal [event_2.title, event_1.title, event_3.title], actual[:results].pluck(:title)
  end

  test "return scheduled events by default" do
    create :streaming_event, :past
    create :streaming_event, :live
    scheduled = create :streaming_event

    actual = AssembleStreamingEvents.({})
    assert_equal [scheduled.title], actual[:results].pluck(:title)
  end

  test "return live events" do
    create :streaming_event, :past
    live = create :streaming_event, :live
    create :streaming_event

    actual = AssembleStreamingEvents.({ live: true })
    assert_equal [live.title], actual[:results].pluck(:title)
  end

  test "results are serialized correctly" do
    freeze_time do
      event = create :streaming_event

      actual = AssembleStreamingEvents.({})
      expected = {
        results: [
          {
            id: event.id,
            title: event.title,
            description: event.description,
            starts_at: event.starts_at,
            ends_at: event.ends_at,
            featured: false,
            thumbnail_url: event.thumbnail_url,
            links: { watch: event.youtube_external_url,
                     embed: event.youtube_embed_url }
          }
        ],
        meta: { current_page: 1, total_count: 1, total_pages: 1 }
      }
      assert_equal expected, actual
    end
  end
end
