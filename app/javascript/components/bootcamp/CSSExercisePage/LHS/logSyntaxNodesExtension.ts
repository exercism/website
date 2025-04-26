import { syntaxTree } from '@codemirror/language'
import { Extension } from '@codemirror/state'
import { EditorView } from '@codemirror/view'

export function logSyntaxNodesExtension(): Extension {
  return EditorView.updateListener.of((update) => {
    if (!update.docChanged && !update.viewportChanged) return

    const tree = syntaxTree(update.state)
    const nodeTypes = new Set<string>()

    tree.iterate({
      enter: (node) => {
        nodeTypes.add(node.name)
      },
    })

    console.log('Syntax node types:', Array.from(nodeTypes))
  })
}
