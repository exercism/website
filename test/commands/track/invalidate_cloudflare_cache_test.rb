require 'test_helper'

class Track::InvalidateCloudflareCacheTest < ActiveSupport::TestCase
  test "purges the track's cached pages and the tracks index" do
    track = create :track, slug: 'ruby'

    Cloudflare::PurgeUrls.expects(:call).with(
      [
        "https://test.exercism.org/tracks/ruby",
        "https://test.exercism.org/tracks/ruby/exercises",
        "https://test.exercism.org/tracks/ruby/concepts",
        "https://test.exercism.org/tracks/ruby/build",
        "https://test.exercism.org/tracks"
      ]
    )

    Track::InvalidateCloudflareCache.(track)
  end
end
