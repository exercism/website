require "test_helper"

class TimeHelperTest < ActionView::TestCase
  test "time_ago_in_words short" do
    assert_equal "now", time_ago_in_words(Time.current, short: true)
    assert_equal "now", time_ago_in_words(Time.current - 1.second, short: true)
    assert_equal "1m", time_ago_in_words(Time.current - 1.minute, short: true)
    assert_equal "30m", time_ago_in_words(Time.current - 30.minutes, short: true)
    assert_equal "1h", time_ago_in_words(Time.current - 1.hour, short: true)
    assert_equal "6h", time_ago_in_words(Time.current - 6.hours, short: true)
    assert_equal "23h", time_ago_in_words(Time.current - 23.hours, short: true)
    assert_equal "1d", time_ago_in_words(Time.current - 40.hours, short: true)
    assert_equal "7d", time_ago_in_words(Time.current - 1.week, short: true)
    assert_equal "28d", time_ago_in_words(Time.current - 1.month, short: true)
    assert_equal "3m", time_ago_in_words(Time.current - 3.months, short: true)
    assert_equal "1y", time_ago_in_words(Time.current - 1.year, short: true)
  end
end
