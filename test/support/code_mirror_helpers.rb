module CodeMirrorHelpers
  def fill_in_editor(code)
    find(".cm-editor").click
    find(".cm-content").send_keys(code)
  end
end
