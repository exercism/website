import {
  EditorView,
  Decoration,
  ViewPlugin,
  ViewUpdate,
} from '@codemirror/view'
import { EditorState, Extension } from '@codemirror/state'

const initialCode = 'function my#'

const readonlyDeco = Decoration.mark({ class: 'readonly' })

const readonlyPlugin = ViewPlugin.fromClass(
  class {
    decorations

    constructor(view: EditorView) {
      this.decorations = Decoration.set([
        readonlyDeco.range(0, initialCode.length),
      ])
    }

    update(update: ViewUpdate) {
      this.decorations = Decoration.set([
        readonlyDeco.range(0, initialCode.length),
      ])
    }
  },
  { decorations: (v) => v.decorations }
)

const readonlyTransactionFilter = EditorState.transactionFilter.of((tr) => {
  if (tr.newDoc.sliceString(0, initialCode.length) !== initialCode) {
    return []
  }
  return [tr]
})

export const ReadonlyFunctionMyExtension: Extension = [
  readonlyPlugin,
  readonlyTransactionFilter,
  EditorView.theme({
    '.readonly': {
      background: '#cccccc88',
      filter: 'grayscale(60%)',
      borderRadius: '4px',
      'pointer-events': 'none',
    },
  }),
]
