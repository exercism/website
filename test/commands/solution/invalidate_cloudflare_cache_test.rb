require 'test_helper'

class Solution::InvalidateCloudflareCacheTest < ActiveSupport::TestCase
  test "purges both the handle and the legacy uuid url" do
    user = create :user, handle: 'iHiD'
    track = create :track, slug: 'ruby'
    exercise = create(:practice_exercise, track:, slug: 'bob')
    solution = create(:practice_solution, user:, exercise:)

    Cloudflare::PurgeUrls.expects(:call).with(
      [
        "https://test.exercism.org/tracks/ruby/exercises/bob/solutions/iHiD",
        "https://test.exercism.org/tracks/ruby/exercises/bob/solutions/#{solution.uuid}"
      ]
    )

    Solution::InvalidateCloudflareCache.(solution)
  end
end
