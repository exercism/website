module ClipboardHelpers
  def assert_clipboard_text(expected)
    clipboard = find("[data-test-clipboard]", visible: false)

    assert_equal expected, clipboard["data-content"]
  end
end
