module AceHelpers
  def fill_in_editor(code)
    find(".ace_text-input", visible: false).set(code)
  end
end
