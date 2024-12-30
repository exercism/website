import { StateEffect, StateField } from '@codemirror/state'
import readOnlyRangesExtension from './readOnlyRangesExtension'

type ReadOnlyRange = { from: number; to: number }
export const updateReadOnlyRangesEffect = StateEffect.define<ReadOnlyRange[]>()
export const readOnlyRangesStateField = StateField.define<ReadOnlyRange[]>({
  create() {
    return []
  },
  update(ranges, tr) {
    if (tr.startState.doc.lines < tr.state.doc.lines) {
      const cursor = tr.state.selection.main.head
      const newLine = tr.state.doc.lineAt(cursor).number
      return ranges.map((r) => {
        const rangeLine = r.from
        if (rangeLine >= newLine) {
          return { from: r.from + 1, to: r.to + 1 }
        } else return r
      })
    }
    if (tr.startState.doc.lines > tr.state.doc.lines) {
      const cursor = tr.state.selection.main.head
      const lineAtCursor = tr.state.doc.lineAt(cursor)
      const lineDeletedAbove = lineAtCursor.number - 1

      return ranges.map((r) => {
        if (r.from > lineDeletedAbove) {
          return { from: r.from - 1, to: r.to - 1 }
        }

        return r
      })
    }

    for (let effect of tr.effects) {
      if (effect.is(updateReadOnlyRangesEffect)) {
        return effect.value
      }
    }

    return ranges
  },
})

export function initReadOnlyRangesExtension() {
  return [
    readOnlyRangesStateField,
    readOnlyRangesExtension((state) => {
      return state.field(readOnlyRangesStateField).map((r) => {
        return {
          from: state.doc.line(r.from).from,
          to: state.doc.line(r.to).to,
        }
      })
    }),
  ]
}
