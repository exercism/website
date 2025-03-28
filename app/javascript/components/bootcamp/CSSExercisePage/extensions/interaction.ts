import { syntaxTree } from '@codemirror/language'
import {
  EditorView,
  ViewUpdate,
  PluginValue,
  ViewPlugin,
} from '@codemirror/view'
import { SyntaxNode } from '@lezer/common'

const COLOR_INPUT_ID = 'editor-color-input'
const FAUX_RANGE_INPUT_ID = 'faux-range'

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
    const fauxRange = document.getElementById(FAUX_RANGE_INPUT_ID)

    if (colorInput && document.activeElement !== colorInput) {
      colorInput.remove()
    }
    if (fauxRange) {
      fauxRange.remove()
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

  handleNumberNode(node: SyntaxNode, view: EditorView) {
    const { top, left, isCursorInside } = cursorPositionHelper(view, node)
    if (!isCursorInside) return

    const currentTree = syntaxTree(view.state)
    const nodeAtCursor = currentTree.resolve(node.from, 1)
    const unitNode = nodeAtCursor.getChild('Unit')

    if (unitNode) {
      const unit = view.state.sliceDoc(unitNode.from, unitNode.to)
      const numberText = view.state.sliceDoc(node.from, unitNode.from).trim()
      let currentNumber = parseFloat(numberText)
      const id = FAUX_RANGE_INPUT_ID

      if (document.getElementById(id)) return

      const fauxRange = document.createElement('div')
      fauxRange.id = id
      Object.assign(fauxRange.style, {
        position: 'absolute',
        top: `${top}px`,
        left: `${left}px`,
        transform: 'translate(-50%, -100%)',
        zIndex: '9999',
        width: '30px',
        height: '30px',
        background: 'red',
        cursor: 'ew-resize',
      })

      let isDragging = false
      let startX = 0
      let currentDelta = 0

      const onMouseMove = (e: MouseEvent) => {
        if (!isDragging) return
        currentDelta = e.clientX - startX
        fauxRange.style.left = `${left + currentDelta}px`

        const currentTree = syntaxTree(view.state)
        const nodeAtCursor = currentTree.resolve(node.from, 1)

        view.dispatch({
          changes: {
            from: nodeAtCursor.from,
            to: nodeAtCursor.to,
            insert: `${currentNumber + currentDelta}${unit}`,
          },
        })
      }

      const onMouseUp = () => {
        isDragging = false

        fauxRange.style.left = `${left}px`

        currentNumber = parseFloat(numberText) + currentDelta

        document.removeEventListener('mousemove', onMouseMove)
        document.removeEventListener('mouseup', onMouseUp)
      }

      fauxRange.addEventListener('mousedown', (e: MouseEvent) => {
        isDragging = true
        startX = e.clientX
        // currentDelta = 0
        document.addEventListener('mousemove', onMouseMove)
        document.addEventListener('mouseup', onMouseUp)
      })

      document.body.appendChild(fauxRange)
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

        const currentTree = syntaxTree(view.state)
        const nodeAtCursor = currentTree.resolve(node.from, -1)
        const newNode = nodeAtCursor.getChild('CallExpression')
        if (!newNode) return

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

    // requestAnimationFrame(() => {
    //   const { top, left, isCursorInside } = cursorPositionHelper(view, node)
    //   if (isCursorInside) {
    //     console.log(
    //       'node',
    //       node.type.name,
    //       view.state.sliceDoc(node.from, node.to)
    //     )
    //   }
    // })
    if (isColorNode) {
      requestAnimationFrame(() => this.handleColorNode(node, view))
    } else if (getIsNumberNode(node)) {
      requestAnimationFrame(() => this.handleNumberNode(node, view))
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

function getIsNumberNode(node: SyntaxNode) {
  return node.type.name === 'NumberLiteral'
}

function traverseTree(node: SyntaxNode, cb: (node: SyntaxNode) => void) {
  const cursor = node.cursor()
  do {
    cb(cursor.node)
  } while (cursor.next())
}
