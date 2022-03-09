require "test_helper"

class TimeHelperTest < ActionView::TestCase
  test "time_ago_in_words" do
    travel_to(Date.new(2022, 6, 3))
    assert_equal "seconds", time_ago_in_words(Time.current)
    assert_equal "seconds", time_ago_in_words(Time.current - 1.second)
    assert_equal "seconds", time_ago_in_words(Time.current - 10.seconds)
    assert_equal "1 minute", time_ago_in_words(Time.current - 30.seconds)
    assert_equal "1 minute", time_ago_in_words(Time.current - 50.seconds)
    assert_equal "1 minute", time_ago_in_words(Time.current - 1.minute)
    assert_equal "30 minutes", time_ago_in_words(Time.current - 30.minutes)
    assert_equal "5 years", time_ago_in_words(Time.current - 5.years)
    assert_equal "over 5 years", time_ago_in_words(Time.current - 5.years - 4.months)
  end

  test "time_ago_in_words short" do
    travel_to(Date.new(2022, 6, 3))
    assert_equal "1s", time_ago_in_words(Time.current, short: true)
    assert_equal "1s", time_ago_in_words(Time.current - 1.second, short: true)
    assert_equal "1m", time_ago_in_words(Time.current - 1.minute, short: true)
    assert_equal "30m", time_ago_in_words(Time.current - 30.minutes, short: true)
    assert_equal "1h", time_ago_in_words(Time.current - 1.hour, short: true)
    assert_equal "6h", time_ago_in_words(Time.current - 6.hours, short: true)
    assert_equal "23h", time_ago_in_words(Time.current - 23.hours, short: true)
    assert_equal "1d", time_ago_in_words(Time.current - 40.hours, short: true)
    assert_equal "7d", time_ago_in_words(Time.current - 1.week, short: true)
    assert_equal "1mo", time_ago_in_words(Time.current - 1.month, short: true)
    assert_equal "3mo", time_ago_in_words(Time.current - 3.months, short: true)
    assert_equal "1y", time_ago_in_words(Time.current - 1.year, short: true)
    assert_equal "5y", time_ago_in_words(Time.current - 5.years, short: true)
    assert_equal "5y+", time_ago_in_words(Time.current - 5.years - 4.months, short: true)
  end
end
