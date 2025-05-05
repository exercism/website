import { COLOR_INPUT_ID } from './handlers/handleColorNode/appendColorInput'
import { FAUX_RANGE_INPUT_ID } from './handlers/handleNumberNode'

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
