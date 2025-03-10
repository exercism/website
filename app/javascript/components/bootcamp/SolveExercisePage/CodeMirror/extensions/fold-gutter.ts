import { foldGutter, syntaxTree, foldService } from '@codemirror/language'
import { EditorState } from '@codemirror/state'
import { SyntaxNode } from '@lezer/common'
import { unfoldableFunctionsField } from '../unfoldableFunctionNames'
import { isEqual } from 'lodash'

const functionFolding = foldService.of((state, _lineStart, lineEnd) => {
  const tree = syntaxTree(state)
  const treeResolve = tree.resolve(lineEnd)
  let node: typeof treeResolve | null = treeResolve

  const unFoldables = state.field(unfoldableFunctionsField, false)
  const currentLine = state.doc.lineAt(lineEnd)

  while (node) {
    if (isFunctionNode(node)) {
      const functionStartLine = state.doc.lineAt(node.from)
      const functionEndLine = state.doc.lineAt(node.to)
      const fnName = getFunctionIdentifier(node, state)

      if (fnName && unFoldables && unFoldables.includes(fnName)) return null

      const firstLineEndPos = functionStartLine.to
      // -3 is the length of "end" which we want to keep
      const functionEndPos = node.to - 3

      if (functionStartLine.number === functionEndLine.number) {
        return null
      }

      if (currentLine.number === functionStartLine.number) {
        return { from: firstLineEndPos, to: functionEndPos }
      }
    }
    node = node.parent
  }

  return null
})

const getFunctionIdentifier = (node: SyntaxNode, state: EditorState) => {
  const identifierNode = node.getChild('FunctionName')
  if (identifierNode) {
    return state.doc.sliceString(identifierNode.from, identifierNode.to)
  }
  return null
}

const isFunctionNode = (node: any) => {
  return node.name === 'FunctionDefinition'
}

export const foldGutterExtension = [
  functionFolding,
  foldGutter({
    foldingChanged: (update) => {
      const startUnfoldable = update.startState.field(
        unfoldableFunctionsField,
        false
      )
      const currentUnfoldable = update.state.field(
        unfoldableFunctionsField,
        false
      )

      // if this returns true, it triggers a recomputation of the fold markers
      return !isEqual(startUnfoldable, currentUnfoldable)
    },
    markerDOM: (open) => {
      const marker = document.createElement('span')
      marker.textContent = open ? '▾' : '▸'
      marker.style.cursor = 'pointer'
      return marker
    },
  }),
]
