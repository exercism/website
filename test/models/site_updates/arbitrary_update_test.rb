require 'test_helper'

class SiteUpdates::ArbitraryUpdateTest < ActiveSupport::TestCase
  test "rendering_data" do
    freeze_time do
      author = create :user, handle: "We"
      track = create :track
      update = create(:arbitrary_site_update, author:, track:)

      expected = {
        text: "<em>We</em> published a new update.",
        icon: {
          type: 'image',
          url: track.icon_url
        },
        track: {
          title: track.title,
          icon_url: track.icon_url
        },
        published_at: (Time.current + 3.hours).iso8601
      }.with_indifferent_access

      assert_equal expected, update.rendering_data
    end
  end

  test "guard_params are random" do
    site_updates = create_list(:arbitrary_site_update, 10, track: create(:track, :random_slug))
    assert_equal site_updates.size, site_updates.map(&:guard_params).uniq.size
  end
end
