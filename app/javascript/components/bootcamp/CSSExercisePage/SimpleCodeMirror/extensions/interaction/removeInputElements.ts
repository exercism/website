export const COLOR_INPUT_ID = 'editor-color-input'
export const FAUX_RANGE_INPUT_ID = 'faux-range'

export function removeInputElements() {
  const colorInput = document.getElementById(COLOR_INPUT_ID)
  const fauxRange = document.getElementById(FAUX_RANGE_INPUT_ID)

  if (colorInput && document.activeElement !== colorInput) {
    colorInput.remove()
  }
  if (fauxRange) {
    fauxRange.remove()
  }
}
