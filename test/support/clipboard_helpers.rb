module ClipboardHelpers
  def assert_clipboard_text(expected)
    assert_css "[data-test-clipboard][data-content='#{expected}']", visible: false
  end
end
