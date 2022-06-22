require "test_helper"
require "hcaptcha"

class TimeExtensionsTest < ActiveSupport::TestCase
  # rubocop:disable Rails/TimeZone
  test "min_of_day on Time instance" do
    assert_equal 0, Time.now.change(hour: 0, min: 0).min_of_day
    assert_equal 59, Time.now.change(hour: 0, min: 59).min_of_day
    assert_equal 60, Time.now.change(hour: 1, min: 0).min_of_day
    assert_equal 1439, Time.now.change(hour: 23, min: 59).min_of_day
  end
  # rubocop:enable Rails/TimeZone

  test "min_of_day on DateTime instance" do
    assert_equal 0, DateTime.now.change(hour: 0, min: 0).min_of_day
    assert_equal 59, DateTime.now.change(hour: 0, min: 59).min_of_day
    assert_equal 60, DateTime.now.change(hour: 1, min: 0).min_of_day
    assert_equal 1439, DateTime.now.change(hour: 23, min: 59).min_of_day
  end

  test "min_of_day on TimeWithZone instance" do
    assert_equal 0, Time.zone.now.change(hour: 0, min: 0).min_of_day
    assert_equal 59, Time.zone.now.change(hour: 0, min: 59).min_of_day
    assert_equal 60, Time.zone.now.change(hour: 1, min: 0).min_of_day
    assert_equal 1439, Time.zone.now.change(hour: 23, min: 59).min_of_day
  end
end
