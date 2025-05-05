import { EditorView } from '@codemirror/view'
import { SyntaxNode } from '@lezer/common'

const COLOR_INPUT_ID = 'editor-color-input'

export function cursorPositionHelper(view: EditorView, node: SyntaxNode) {
  const cursorPos = view.state.selection.main.head
  const coords = view.coordsAtPos(cursorPos)
  const isCursorInside = node.from <= cursorPos && cursorPos <= node.to
  return {
    isCursorInside,
    top: coords?.top || 0,
    left: coords?.left || 0,
  }
}

export function hex2rgb(hex: string): [number, number, number] {
  const v = parseInt(hex.substring(1), 16)
  return [(v >> 16) & 255, (v >> 8) & 255, v & 255]
}

export function rgb2hex(r: number, g: number, b: number): string {
  return `#${r.toString(16)}${g.toString(16)}${b.toString(16)}`
}

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

export function formatColorInputDefaultValue(input: string): string {
  if (input.startsWith('#')) return input

  const match = input.match(/rgb\s*\((\d+),\s*(\d+),\s*(\d+)\)/)
  if (match) {
    const [r, g, b] = match.slice(1).map(Number)
    return rgb2hex(r, g, b)
  }

  return '#000000'
}
