import { formatColorInputDefaultValue } from './formatColorInputDefaultValue'

export const COLOR_INPUT_ID = 'editor-color-input'

export function appendColorInput({
  top,
  left,
  defaultValue,
  onChange,
  id = 'editor-color-input',
}: {
  top: number
  left: number
  defaultValue: string
  onChange: (color: string) => void
  id?: string
}) {
  const colorInput = document.createElement('input')
  colorInput.id = id
  colorInput.type = 'color'
  colorInput.value = formatColorInputDefaultValue(defaultValue)
  Object.assign(colorInput.style, {
    position: 'absolute',
    top: top + 'px',
    left: left + 'px',
    transform: 'translate(-50%, -100%)',
    zIndex: '9999',
    width: '40px',
    height: '40px',
    padding: '0',
    border: 'none',
  })

  colorInput.onclick = (e) => {
    e.stopPropagation()
    e.stopImmediatePropagation()
  }

  colorInput.oninput = (e) => {
    const color = (e.target as HTMLInputElement).value
    onChange(color)
  }

  if (document.getElementById(COLOR_INPUT_ID) === null) {
    document.body.appendChild(colorInput)
  }
}
