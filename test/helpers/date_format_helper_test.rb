require "test_helper"

class DateFormatHelperTest < ActionView::TestCase
  test "english dates use ordinals" do
    assert_equal "28th Sep 2026", format_date(Time.utc(2026, 9, 28, 14, 5))
    assert_equal "28th Sep 2026, 14:05 UTC", format_datetime(Time.utc(2026, 9, 28, 14, 5))
  end

  test "other locales use their long date format" do
    I18n.with_locale(:ja) do
      assert_equal "2026年09月28日", format_date(Time.utc(2026, 9, 28, 14, 5))
      assert_equal "2026年09月28日, 14:05 UTC", format_datetime(Time.utc(2026, 9, 28, 14, 5))
    end
  end
end
