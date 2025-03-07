import {
  foldState,
  foldGutter,
  syntaxTree,
  foldService,
} from '@codemirror/language'

const isFunctionNode = (node: any) => {
  return node.name === 'FunctionDefinition'
}

const functionFolding = foldService.of((state, lineStart, lineEnd) => {
  const tree = syntaxTree(state)
  const treeResolve = tree.resolve(lineEnd)
  let node: typeof treeResolve | null = treeResolve

  while (node) {
    if (isFunctionNode(node)) {
      const functionStartLine = state.doc.lineAt(node.from)
      const functionEndLine = state.doc.lineAt(node.to)
      const currentLine = state.doc.lineAt(lineEnd)

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

export const foldGutterExtension = [
  functionFolding,
  foldState,
  foldGutter({
    markerDOM: (open) => {
      const marker = document.createElement('span')
      marker.textContent = open ? '▾' : '▸'
      marker.style.cursor = 'pointer'
      return marker
    },
  }),
]
