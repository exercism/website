module MarkdownEditorHelpers
  def fill_in_editor(text)
    execute_script("document.querySelector('.CodeMirror').CodeMirror.setValue('#{text}')")
  end
end
