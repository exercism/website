import { EditorView, Decoration, type DecorationSet } from '@codemirror/view'
import { StateField, StateEffect } from '@codemirror/state'
import { cleanUpEditorEffect } from './clean-up-editor'

export const addUnderlineEffect = StateEffect.define<{
  from: number
  to: number
}>({
  map: ({ from, to }, change) => ({
    from: change.mapPos(from),
    to: change.mapPos(to),
  }),
})

export const underlineField = StateField.define<DecorationSet>({
  create() {
    return Decoration.none
  },
  update(underlines, tr) {
    if (tr.docChanged) {
      return Decoration.none
    }
    let updatedUnderlines = underlines.map(tr.changes)
    for (let e of tr.effects) {
      if (e.is(cleanUpEditorEffect)) {
        updatedUnderlines = Decoration.none
      }
      if (e.is(addUnderlineEffect)) {
        const { from, to } = e.value
        if (from === 0 && to === 0) {
          return Decoration.none
        }
        if (from >= 0 && to <= tr.newDoc.length) {
          updatedUnderlines = Decoration.none.update({
            add: [underlineMark.range(from, to)],
          })
        }
      }
    }
    return updatedUnderlines
  },
  provide: (f) => EditorView.decorations.from(f),
})

const underlineMark = Decoration.mark({ class: 'cm-underline' })

// styling for .cm-underline is in codemirror.css
export function underlineExtension({
  underlineStyle,
}: { underlineStyle?: string } = {}) {
  const defaultStyle = underlineStyle || 'underline 2px red'
  const underlineTheme = EditorView.baseTheme({
    '.cm-underline': { textDecoration: defaultStyle },
  })
  return [underlineField, underlineTheme]
}
