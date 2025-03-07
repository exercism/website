import {
  foldState,
  foldGutter,
  syntaxTree,
  foldService,
} from '@codemirror/language'

const isFunctionNode = (node: any) => {
  return node.firstChild === 'FunctionDeclaration'
}

const functionFolding = foldService.of((state, lineStart, lineEnd) => {
  const tree = syntaxTree(state)
  const treeResolve = tree.resolve(lineStart)
  let node: typeof treeResolve | null = treeResolve

  // console.log('line start', lineStart, state.doc.lineAt(lineStart).number)
  while (node) {
    const currentLine = state.doc.lineAt(lineStart).number
    // console.log('node at line', currentLine, node)
    if (isFunctionNode(node)) {
      // const functionStartLine = state.doc.lineAt(node.from).number
      const currentLine = state.doc.lineAt(lineStart).number
      // console.log('currentLine', currentLine)
      // console.log('function start line', functionStartLine, currentLine)

      // // Only add the fold marker on the function's starting line
      // if (functionStartLine === currentLine) {
      //   console.log('fn node line', functionStartLine)
      //   console.log('node.from', node.from, node.to)

      //   let headerEnd = node.lastChild?.from

      return { from: node.from, to: node.to }
      // }
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
