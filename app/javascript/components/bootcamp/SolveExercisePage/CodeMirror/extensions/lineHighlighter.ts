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

export const INFO_HIGHLIGHT_COLOR = '#dadaff88'
export const ERROR_HIGHLIGHT_COLOR = '#fecaca88'

export const changeLineEffect = StateEffect.define<number>()

export const highlightedLineField = StateField.define<number>({
  create() {
    return 1
  },
  update(value, tr) {
    for (const effect of tr.effects) {
      if (effect.is(changeLineEffect)) {
        return effect.value
      }
    }
    return value
  },
})

export const changeColorEffect = StateEffect.define<string>()

export const highlightColorField = StateField.define<string>({
  create() {
    return INFO_HIGHLIGHT_COLOR
  },
  update(value, tr) {
    for (const effect of tr.effects) {
      if (effect.is(changeColorEffect)) {
        return effect.value
      }
    }
    return value
  },
})

// Base theme for highlighting
const baseTheme = EditorView.baseTheme({
  '&light .cm-highlightedLine': { backgroundColor: INFO_HIGHLIGHT_COLOR },
  '&dark .cm-highlightedLine': { backgroundColor: '#1a272788' },
})

// Decoration for highlighting a line
function stripe(color: string) {
  return Decoration.line({
    attributes: {
      class: 'cm-highlightedLine',
      style: `background-color: ${color}`,
    },
  })
}

// Function to create line decorations based on the current state
function stripeDeco(view: EditorView) {
  let builder = new RangeSetBuilder<Decoration>()
  const lineNumber = view.state.field(highlightedLineField)
  const color = view.state.field(highlightColorField)

  for (let { from, to } of view.visibleRanges) {
    for (let pos = from; pos <= to; ) {
      let line = view.state.doc.lineAt(pos)
      if (line.number == lineNumber)
        builder.add(line.from, line.from, stripe(color))
      pos = line.to + 1
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

export function highlightLine(initialLineNumber: number): Extension {
  return [
    baseTheme,
    highlightedLineField.init(() => initialLineNumber),
    highlightColorField.init(() => INFO_HIGHLIGHT_COLOR),
    showStripes,
  ]
}
