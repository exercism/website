module MarkdownEditorHelpers
  def fill_in_editor(text)
    sleep(0.5)
    execute_script("document.querySelector('.CodeMirror').CodeMirror.setValue('#{text}')")
  end

  def assert_editor_text(expected)
    sleep(0.5)
    actual = evaluate_script("document.querySelector('.CodeMirror').CodeMirror.getValue()")

    assert_equal expected, actual
  end
end
