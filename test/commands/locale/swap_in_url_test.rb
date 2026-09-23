require "test_helper"

class Locale::SwapInUrlTest < ActiveSupport::TestCase
  test "swaps the locale in the path" do
    assert_equal "https://exercism.org/hu/tracks", Locale::SwapInUrl.("https://exercism.org/tracks", :hu)
    assert_equal "https://exercism.org/tracks", Locale::SwapInUrl.("https://exercism.org/hu/tracks", :en)
  end

  test "keeps the query string" do
    url = Locale::SwapInUrl.("https://exercism.org/tracks?criteria=ruby", :hu)
    assert_equal "https://exercism.org/hu/tracks?criteria=ruby", url
  end

  test "has no trailing slash" do
    assert_equal "https://exercism.org/hu", Locale::SwapInUrl.("https://exercism.org/", :hu)
    assert_equal "https://exercism.org", Locale::SwapInUrl.("https://exercism.org/hu", :en)
  end
end
