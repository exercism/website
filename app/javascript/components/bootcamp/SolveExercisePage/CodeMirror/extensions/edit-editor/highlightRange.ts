import { Decoration, type DecorationSet, EditorView } from '@codemirror/view'
import { StateEffect, StateField } from '@codemirror/state'

export const addHighlight = StateEffect.define<{ from: number; to: number }>({
  map: ({ from, to }, change) => ({
    from: change.mapPos(from),
    to: change.mapPos(to),
  }),
})
export const removeAllHighlightEffect = StateEffect.define<void>({})

export const highlightField = StateField.define<DecorationSet>({
  create() {
    return Decoration.none
  },
  update(highlights, tr) {
    if (tr.effects.some((e) => e.is(removeAllHighlightEffect))) {
      return Decoration.none
    }

    highlights = highlights.map(tr.changes)
    for (let e of tr.effects)
      if (e.is(addHighlight)) {
        highlights = highlights.update({
          add: [highlightMark.range(e.value.from, e.value.to)],
        })
      }
    return highlights
  },
  provide: (f) => EditorView.decorations.from(f),
})

const highlightMark = Decoration.mark({ class: 'cm-highlighted-code' })

export const highlightTheme = EditorView.baseTheme({
  '.cm-highlighted-code': {
    background: '#C2DEF3',
    border: '1px solid #2E57E8',
    borderRadius: '4px',
    padding: '2px',
  },
})

export function highlightedCodeBlock() {
  return [highlightTheme, highlightField]
}
