require 'test_helper'

class Concept::InvalidateCloudflareCacheTest < ActiveSupport::TestCase
  test "purges the concept and the track's concepts index" do
    track = create :track, slug: 'ruby'
    concept = create :concept, track:, slug: 'strings'

    Cloudflare::PurgeUrls.expects(:call).with(
      [
        "https://test.exercism.org/tracks/ruby/concepts/strings",
        "https://test.exercism.org/tracks/ruby/concepts"
      ]
    )

    Concept::InvalidateCloudflareCache.(concept)
  end
end
