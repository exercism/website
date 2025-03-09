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
import { showInfoWidgetField } from './end-line-information/line-information'

export const INFO_HIGHLIGHT_COLOR = '#f9f9ff'
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
  '&light .cm-highlightedLine': {
    backgroundColor: INFO_HIGHLIGHT_COLOR,
  },
  '&dark .cm-highlightedLine': { backgroundColor: '#1a272788' },
})

// Decoration for highlighting a line
function stripe(color: string) {
  return Decoration.line({
    attributes: {
      class: 'cm-highlightedLine',
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

function updateHighlightedLineBorder() {
  return EditorView.updateListener.of((update) => {
    if (update.state.field(showInfoWidgetField)) {
      const highlightColor = update.state.field(highlightColorField)

      const borderColor =
        highlightColor === INFO_HIGHLIGHT_COLOR ? '#3b82f6' : '#ff000077'

      update.view.dom.style.setProperty(
        '--highlighted-line-background-color',
        highlightColor
      )
      update.view.dom.style.setProperty(
        '--highlighted-line-border-color',
        borderColor
      )
    } else {
      update.view.dom.style.setProperty(
        '--highlighted-line-background-color',
        'transparent'
      )
      update.view.dom.style.setProperty(
        '--highlighted-line-border-color',
        'transparent'
      )
    }
  })
}

export function highlightLine(initialLineNumber: number): Extension {
  return [
    baseTheme,
    updateHighlightedLineBorder(),
    highlightedLineField.init(() => initialLineNumber),
    highlightColorField.init(() => INFO_HIGHLIGHT_COLOR),
    showStripes,
  ]
}
