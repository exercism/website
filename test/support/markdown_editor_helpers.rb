module MarkdownEditorHelpers
  def fill_in_editor(text, within: "")
    wait_for_editor_to_load
    execute_script("document.querySelector('#{within} .CodeMirror').CodeMirror.setValue('#{text}')")
  end

  def assert_editor_text(expected)
    wait_for_editor_to_load
    actual = evaluate_script("document.querySelector('.CodeMirror').CodeMirror.getValue()")

    assert_equal expected, actual
  end

  def wait_for_editor_to_load = sleep(0.5)

  def open_editor = find(".c-markdown-editor").click
end
