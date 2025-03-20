import { syntaxTree } from '@codemirror/language'
import {
  EditorView,
  ViewUpdate,
  PluginValue,
  ViewPlugin,
} from '@codemirror/view'
import { SyntaxNode } from '@lezer/common'

const COLOR_INPUT_ID = 'editor-color-input'

class ValueInteractor implements PluginValue {
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

  handleColorNode(node: SyntaxNode, view: EditorView) {
    const { top, left, isCursorInside } = cursorPositionHelper(view, node)
    if (!isCursorInside) return
    const nodeContent = view.state.sliceDoc(node.from, node.to)
    this.appendColorInput({
      top,
      left,
      defaultValue: nodeContent,
      onChange: (color: string) => {
        const [rVal, gVal, bVal] = hex2rgb(color)

        const nodeContent = view.state.sliceDoc(node.from, node.to)
        console.log('nodeContent', nodeContent)
        const currentTree = syntaxTree(view.state)
        const nodeAtCursor = currentTree.resolve(node.from, -1)
        const newNode = nodeAtCursor.getChild('CallExpression')
        if (!newNode) return
        console.log(
          'nodeAtCursor',
          view.state.sliceDoc(newNode.from, newNode.to)
        )

        const argListNode = node.getChild('ArgList')
        if (!argListNode) return

        const numLiterals = argListNode.getChildren('NumberLiteral')
        if (numLiterals.length === 0) return

        view.dispatch({
          changes: {
            from: newNode.from,
            to: newNode.to,
            insert: `rgb(${rVal}, ${gVal}, ${bVal})`,
          },
        })
      },
    })
  }

  handleNode(node: SyntaxNode, view: EditorView) {
    const isColorNode = getIsColorNode(view, node)

    if (isColorNode) {
      requestAnimationFrame(() => this.handleColorNode(node, view))
    }
  }
}

export function interactionExtension() {
  return ViewPlugin.fromClass(ValueInteractor)
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

function getIsColorNode(view: EditorView, node: SyntaxNode) {
  return getIsHexNode(node) || getIsRgbNode(view, node)
}

function getIsRgbNode(view: EditorView, node: SyntaxNode) {
  const nodeContent = view.state.sliceDoc(node.from, node.to)
  return node.type.name === 'CallExpression' && nodeContent.startsWith('rgb')
}

function getIsHexNode(node: SyntaxNode) {
  return node.type.name === 'ColorLiteral'
}

function traverseTree(node: SyntaxNode, cb: (node: SyntaxNode) => void) {
  const cursor = node.cursor()
  do {
    cb(cursor.node)
  } while (cursor.next())
}
