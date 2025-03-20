import { syntaxTree } from '@codemirror/language'
import {
  EditorView,
  ViewUpdate,
  PluginValue,
  ViewPlugin,
} from '@codemirror/view'
import { SyntaxNode } from '@lezer/common'

const COLOR_INPUT_ID = 'editor-color-input'

class SyntaxTreeLogger implements PluginValue {
  private view: EditorView

  constructor(view: EditorView) {
    this.view = view
    this.traverseSyntaxTree(view)
  }

  update(update: ViewUpdate) {
    if (update.selectionSet) {
      this.removeInputElements()
      this.traverseSyntaxTree(update.view)
    }
  }

  traverseSyntaxTree(view: EditorView) {
    const tree = syntaxTree(view.state)
    this.traverse(tree.topNode, view)
  }

  traverse(node: SyntaxNode, view: EditorView) {
    this.handleNode(node, view)

    for (let child = node.firstChild; child; child = child.nextSibling) {
      this.traverse(child, view)
    }
  }

  removeInputElements() {
    const colorInput = document.getElementById(COLOR_INPUT_ID)

    if (colorInput && document.activeElement !== colorInput) {
      colorInput.remove()
    }
  }

  appendColorInput({
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

  handleNode(node: SyntaxNode, view: EditorView) {
    const nodeContent = view.state.sliceDoc(node.from, node.to)
    const isItHexNode = node.type.name === 'ColorLiteral'
    const isItRgbNode =
      node.type.name === 'CallExpression' && nodeContent.startsWith('rgb')
    const isItColorNode = isItHexNode || isItRgbNode
    const { top, left, isCursorInside } = cursorPositionHelper(view, node)

    if (isItColorNode && isCursorInside) {
      this.appendColorInput({
        top,
        left,
        defaultValue: nodeContent,
        onChange: (color: string) => {
          const newColorString = formattedHex2Rgb(color)

          const newString = view.state
            .sliceDoc(node.from, node.to)
            .replace(
              /rgba?\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*(?:,\s*(?:0|1|0?\.\d+))?\s*\)/,
              newColorString
            )

          this.view.dispatch({
            changes: {
              from: node.from,
              to: node.to,
              insert: newString,
            },
          })
        },
      })
    }
  }
}

export function interactionExtension() {
  return ViewPlugin.fromClass(SyntaxTreeLogger)
}

function hex2rgb(hex: string): [number, number, number] {
  const v = parseInt(hex.substring(1), 16)
  return [(v >> 16) & 255, (v >> 8) & 255, v & 255]
}

function formattedHex2Rgb(hex: string) {
  return `rgb(${hex2rgb(hex).join(', ')})`
}

function rgb2hex(r: number, g: number, b: number): string {
  return '#' + r.toString(16) + g.toString(16) + b.toString(16)
}

function formatColorInputDefaultValue(string: string) {
  if (string.startsWith('rgb')) {
    const rgb = string.match(/\d+/g)
    if (!rgb) return string
    return rgb2hex(parseInt(rgb[0]), parseInt(rgb[1]), parseInt(rgb[2]))
  }

  return string
}

function cursorPositionHelper(view: EditorView, node: SyntaxNode) {
  const cursorPos = view.state.selection.main.head
  const coords = view.coordsAtPos(cursorPos)
  let top = 0,
    left = 0
  if (coords) {
    top = coords.top
    left = coords.left
  }

  const isCursorInside = node.from <= cursorPos && cursorPos <= node.to

  return { isCursorInside, top, left }
}
