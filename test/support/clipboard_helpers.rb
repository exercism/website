module ClipboardHelpers
  def assert_clipboard_text(expected)
    assert find(%([data-test-clipboard][data-content="#{expected}"]), visible: false)
  end
end
