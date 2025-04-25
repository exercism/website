import {
  EditorView,
  ViewUpdate,
  ViewPlugin,
  Decoration,
  type DecorationSet,
} from '@codemirror/view'
import {
  type Extension,
  StateField,
  StateEffect,
  RangeSetBuilder,
} from '@codemirror/state'
import { highlightColorField, INFO_HIGHLIGHT_COLOR } from './lineHighlighter'

export const changeMultiLineHighlightEffect = StateEffect.define<{
  from: number
  to: number
}>()

export const multiHighlightedLineField = StateField.define<{
  from: number
  to: number
}>({
  create() {
    return { from: 0, to: 0 }
  },
  update(value, tr) {
    for (const effect of tr.effects) {
      if (effect.is(changeMultiLineHighlightEffect)) {
        return effect.value
      }
    }
    return value
  },
})

const baseTheme = EditorView.baseTheme({
  '&light .cm-highlightedLine': { backgroundColor: INFO_HIGHLIGHT_COLOR },
  '&dark .cm-highlightedLine': { backgroundColor: '#1a272788' },
})

function stripe(color: string) {
  return Decoration.line({
    attributes: {
      class: 'cm-highlightedLine',
      style: `background-color: ${color}`,
    },
  })
}

function stripeDeco(view: EditorView) {
  let builder = new RangeSetBuilder<Decoration>()
  const lineNumberRange = view.state.field(multiHighlightedLineField)
  const color = view.state.field(highlightColorField)

  let { from, to } = lineNumberRange
  if (from === 0) return builder.finish()
  to = to > view.state.doc.lines ? view.state.doc.lines : to
  console.log('from', from, 'to', to, 'color', color)
  if (from === to) {
    builder.add(from, from, stripe(color))
  } else {
    for (let i = lineNumberRange.from; i <= lineNumberRange.to; i++) {
      let line = view.state.doc.line(i)
      builder.add(line.from, line.from, stripe(color))
    }
  }

  return builder.finish()
}

const showStripes = ViewPlugin.fromClass(
  class {
    decorations: DecorationSet

    constructor(view: EditorView) {
      this.decorations = stripeDeco(view)
    }

    update(update: ViewUpdate) {
      this.decorations = stripeDeco(update.view)
    }
  },
  {
    decorations: (v) => v.decorations,
  }
)

export function multiHighlightLine({
  from,
  to,
}: Record<'from' | 'to', number>): Extension {
  return [
    baseTheme,
    multiHighlightedLineField.init(() => ({
      from,
      to,
    })),
    highlightColorField.init(() => INFO_HIGHLIGHT_COLOR),
    showStripes,
  ]
}
