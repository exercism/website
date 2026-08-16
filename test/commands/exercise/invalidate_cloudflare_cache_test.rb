require 'test_helper'

class Exercise::InvalidateCloudflareCacheTest < ActiveSupport::TestCase
  test "purges the exercise, its dig deeper page, and its approaches and articles" do
    track = create :track, slug: 'ruby'
    exercise = create(:practice_exercise, track:, slug: 'bob')
    create(:exercise_approach, exercise:, slug: 'gsub')
    create(:exercise_article, exercise:, slug: 'performance')

    Cloudflare::PurgeUrls.expects(:call).with(
      [
        "https://test.exercism.org/tracks/ruby/exercises/bob",
        "https://test.exercism.org/tracks/ruby/exercises/bob/dig_deeper",
        "https://test.exercism.org/tracks/ruby/exercises/bob/approaches/gsub",
        "https://test.exercism.org/tracks/ruby/exercises/bob/articles/performance"
      ]
    )

    Exercise::InvalidateCloudflareCache.(exercise)
  end

  test "handles an exercise with no approaches or articles" do
    track = create :track, slug: 'ruby'
    exercise = create(:practice_exercise, track:, slug: 'bob')

    Cloudflare::PurgeUrls.expects(:call).with(
      [
        "https://test.exercism.org/tracks/ruby/exercises/bob",
        "https://test.exercism.org/tracks/ruby/exercises/bob/dig_deeper"
      ]
    )

    Exercise::InvalidateCloudflareCache.(exercise)
  end
end
