require "test_helper"

class CountryTest < ActiveSupport::TestCase
  test "name_for returns the country name" do
    assert_equal "Netherlands", Country.name_for("NL")
    assert_equal "United Kingdom", Country.name_for("GB")
  end

  test "name_for upcases the code" do
    assert_equal "Japan", Country.name_for("jp")
  end

  test "name_for returns nil for a blank or unknown code" do
    assert_nil Country.name_for(nil)
    assert_nil Country.name_for("")
    assert_nil Country.name_for("ZZ")
  end

  test "name_for handles every code Cloudflare can send" do
    assert_equal 273, Country.names.size
    assert(Country.names.all? { |code, name| code.match?(/\A[A-Z]{2}\z/) && name.present? })
  end
end
