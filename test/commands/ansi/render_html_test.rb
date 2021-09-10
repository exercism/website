require 'test_helper'

class Ansi::RenderHTMLTest < ActiveSupport::TestCase
  test "nil text" do
    assert_nil Ansi::RenderHTML.(nil)
  end

  test "empty text" do
    assert_equal "", Ansi::RenderHTML.("")
  end

  test "text without ANSI codes" do
    assert_equal "1 passed, 2 failed", Ansi::RenderHTML.("1 passed, 2 failed")
  end

  test "text with ANSI codes" do
    expected = "<span style='color:#0A0;'>1 passed</span>, <span style='color:#A00;'>2 failed</span>"
    assert_equal expected, Ansi::RenderHTML.("\u001b[32m1 passed\u001b[0m, \u001b[31m2 failed")
  end

  test "ignores unicode escape sequences" do
    assert_equal "1 passed, 2 failed", Ansi::RenderHTML.("\e\[K1 passed, 2 failed")
  end

  test "escapes HTML" do
    assert_equal "I &lt;am/&gt; foo", Ansi::RenderHTML.("I <am/> foo")
  end
end
