import {
  EditorView,
  ViewUpdate,
  PluginValue,
  ViewPlugin,
} from '@codemirror/view'
import { syntaxTree } from '@codemirror/language'
import {
  findNodeAtCursor,
  handleNode,
  removeInputElements,
} from './nodeHandlers'

export class ValueInteractor implements PluginValue {
  constructor(private view: EditorView) {
    requestAnimationFrame(() => this.findAndHandleNode(this.view))
  }

  update(update: ViewUpdate) {
    if (update.selectionSet) {
      removeInputElements()
      requestAnimationFrame(() => this.findAndHandleNode(update.view))
    }
  }

  findAndHandleNode(view: EditorView) {
    const tree = syntaxTree(view.state)
    const cursorPos = view.state.selection.main.head
    findNodeAtCursor(tree.topNode, cursorPos, (node) => handleNode(node, view))
  }
}

export function interactionExtension() {
  return ViewPlugin.fromClass(ValueInteractor)
}
