require "test_helper"

class Locale::SwapInPathTest < ActiveSupport::TestCase
  test "adds a prefix" do
    assert_equal "/hu/tracks/ruby", Locale::SwapInPath.("/tracks/ruby", :hu)
    assert_equal "/hu", Locale::SwapInPath.("/", :hu)
    assert_equal "/hu", Locale::SwapInPath.("", :hu)
  end

  test "english is naked" do
    assert_equal "/tracks/ruby", Locale::SwapInPath.("/hu/tracks/ruby", :en)
    assert_equal "/", Locale::SwapInPath.("/hu", :en)
    assert_equal "/tracks", Locale::SwapInPath.("/en/tracks", :en)
  end

  test "keeps the query string, and adds nothing to it" do
    assert_equal "/hu/tracks?criteria=ruby&page=2", Locale::SwapInPath.("/tracks?criteria=ruby&page=2", :hu)
    assert_equal "/?a=1", Locale::SwapInPath.("/hu?a=1", :en)
  end

  test "is idempotent" do
    assert_equal "/hu/tracks", Locale::SwapInPath.("/hu/tracks", :hu)
  end

  test "only an exact locale is stripped" do
    assert_equal "/hu/hungarian/notes", Locale::SwapInPath.("/hungarian/notes", :hu)
    assert_equal "/hu/hu-lang", Locale::SwapInPath.("/hu-lang", :hu)
    assert_equal "/hu/es-419/x", Locale::SwapInPath.("/es-419/x", :hu)
    assert_equal "/hu/tracks/hu", Locale::SwapInPath.("/tracks/hu", :hu)
  end
end
