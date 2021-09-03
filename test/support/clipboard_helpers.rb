module ClipboardHelpers
  def assert_clipboard_text(expected)
    elements = all("[data-test-clipboard]", visible: false)
    assert elements.any? do |elem|
      elem["data-content"] == expected
    end
  end
end
