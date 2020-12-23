module MarkdownEditorHelpers
  def fill_in_editor(text)
    execute_script("document.querySelector('.CodeMirror').CodeMirror.setValue('#{text}')")
  end

  def assert_editor_text(expected)
    actual = evaluate_script("document.querySelector('.CodeMirror').CodeMirror.getValue()")

    assert_equal expected, actual
  end
end
