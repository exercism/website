import {
  EditorView,
  ViewUpdate,
  PluginValue,
  ViewPlugin,
} from '@codemirror/view'
import { syntaxTree } from '@codemirror/language'
import { handleNode, removeInputElements, traverseTree } from './nodeHandlers'

export class ValueInteractor implements PluginValue {
  constructor(private view: EditorView) {
    this.traverseSyntaxTree(view)
  }

  update(update: ViewUpdate) {
    if (update.selectionSet) {
      removeInputElements()
      this.traverseSyntaxTree(update.view)
    }
  }

  traverseSyntaxTree(view: EditorView) {
    const tree = syntaxTree(view.state)
    traverseTree(tree.topNode, (node) => handleNode(node, view))
  }
}

export function interactionExtension() {
  return ViewPlugin.fromClass(ValueInteractor)
}
