import { syntaxTree } from '@codemirror/language'
import {
  EditorView,
  ViewUpdate,
  PluginValue,
  ViewPlugin,
} from '@codemirror/view'
import { SyntaxNode } from '@lezer/common'

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
    // console.clear()
    this.traverse(tree.topNode, view)
  }

  traverse(node: SyntaxNode, view: EditorView, depth = 0) {
    this.handleNode(node, view, depth)

    for (let child = node.firstChild; child; child = child.nextSibling) {
      this.traverse(child, view, depth + 1)
    }
  }

  removeInputElements() {
    const colorInput = document.getElementById('editor-color-input')

    if (colorInput && document.activeElement !== colorInput) {
      colorInput.remove()
    }
  }

  handleNode(node: SyntaxNode, view: EditorView, depth: number) {
    // this.removeInputElements()
    const cursorPos = view.state.selection.main.head
    const nodeContent = view.state.sliceDoc(node.from, node.to)
    const isCursorInside = node.from <= cursorPos && cursorPos <= node.to
    let topPosition = 0
    let leftPosition = 0
    const colorInputId = 'editor-color-input'

    if (
      (node.type.name === 'ColorLiteral' ||
        (node.type.name === 'CallExpression' &&
          nodeContent.startsWith('rgb'))) &&
      isCursorInside
    ) {
      requestAnimationFrame(() => {
        const nodeSlice = view.state.sliceDoc(node.from, node.to)
        const coords = view.coordsAtPos(cursorPos)
        if (coords) {
          topPosition = Math.round(coords.top)
          leftPosition = Math.round(coords.left)
        }

        const colorInput = document.createElement('input')
        colorInput.id = colorInputId
        colorInput.type = 'color'
        colorInput.value = nodeContent
        Object.assign(colorInput.style, {
          position: 'absolute',
          top: topPosition + 'px',
          left: leftPosition + 'px',
          transform: 'translate(-50%, -100%)',
          zIndex: '9999',
          width: '40px',
          height: '40px',
          padding: '0',
          border: 'none',
        })

        colorInput.addEventListener('click', (e) => {
          e.stopPropagation()
          e.stopImmediatePropagation()
        })

        colorInput.addEventListener('input', (e) => {
          const color = (e.target as HTMLInputElement).value
          const newColorString = formattedHex2Rgb(color)

          const newString = view.state
            .sliceDoc(node.from, node.to)
            .replace(/rgb\(\d+,\s*\d+,\s*\d+\)/, newColorString)

          console.log(newColorString, newString)

          this.view.dispatch({
            changes: {
              from: node.from,
              to: node.to,
              insert: newString,
            },
          })
        })

        if (document.getElementById(colorInputId) === null) {
          document.body.appendChild(colorInput)
        }
      })
    }

    // console.log(
    //   `${node.type.name} [${node.from}, ${node.to}] "${nodeContent}" ${
    //     isCursorInside ? '=== cursor is inside === ' : ''
    //   }`
    // )
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
