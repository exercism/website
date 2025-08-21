import {
  Decoration,
  type DecorationSet,
  EditorView,
  ViewPlugin,
  ViewUpdate,
} from '@codemirror/view'
import { StateEffect, StateField } from '@codemirror/state'
import { placeholderTheme } from '../placeholder-widget'
import { InformationWidget } from './information-widget'
import { highlightedLineField } from '../lineHighlighter'

export const showInfoWidgetEffect = StateEffect.define<boolean>()

export const showInfoWidgetField = StateField.define<boolean>({
  create() {
    return false
  },
  update(value, tr) {
    for (const effect of tr.effects) {
      if (effect.is(showInfoWidgetEffect)) {
        return effect.value
      }
    }
    return value
  },
})

export type InformationWidgetData = {
  html: string
  line: number
  status: 'ERROR' | 'SUCCESS'
}
export const informationWidgetDataEffect =
  StateEffect.define<InformationWidgetData>()

export const informationWidgetDataField =
  StateField.define<InformationWidgetData>({
    create() {
      return { html: '', line: 0, status: 'SUCCESS' }
    },
    update(value, tr) {
      if (tr.docChanged) {
        return { html: '', line: 1, status: 'SUCCESS' }
      }
      for (const effect of tr.effects) {
        if (effect.is(informationWidgetDataEffect)) {
          return effect.value
        }
      }
      return value
    },
  })

function lineInformationWidget(
  view: EditorView,
  onClose: (view: EditorView) => void
): DecorationSet {
  let widgets: any[] = []

  const shouldShowWidget = view.state.field(showInfoWidgetField)
  const widgetData = view.state.field(informationWidgetDataField)

  if (widgetData.line > view.state.doc.lines || widgetData.line === 0)
    return Decoration.none
  if (!shouldShowWidget) return Decoration.none

  const { html, status } = widgetData

  let deco = Decoration.widget({
    widget: new InformationWidget(html, status, view, onClose),
    side: 1,
  })
  let lastPosOfLine = view.state.doc.line(widgetData.line).to

  widgets.push(deco.range(lastPosOfLine))

  return Decoration.set(widgets)
}

class EndlineDecoration {
  placeholders: DecorationSet
  onClose: (view: EditorView) => void
  constructor(view: EditorView, onClose: (view: EditorView) => void) {
    this.onClose = onClose
    this.placeholders = lineInformationWidget(view, this.onClose)
  }
  update(update: ViewUpdate) {
    if (
      update.docChanged ||
      update.viewportChanged ||
      update.startState.field(highlightedLineField) !==
        update.state.field(highlightedLineField) ||
      update.startState.field(showInfoWidgetField) !==
        update.state.field(showInfoWidgetField) ||
      update.startState.field(informationWidgetDataField) !==
        update.state.field(informationWidgetDataField)
    ) {
      this.placeholders = lineInformationWidget(update.view, this.onClose)
    }
  }
}

function endlineDecoration(onClose: (view: EditorView) => void) {
  return ViewPlugin.define(
    (view) => {
      return new EndlineDecoration(view, onClose)
    },
    {
      decorations: (instance) => instance.placeholders,
      provide: (plugin) => {
        return EditorView.atomicRanges.of((view) => {
          return view.plugin(plugin)?.placeholders || Decoration.none
        })
      },
    }
  )
}

export function lineInformationExtension({
  onClose,
}: {
  onClose: (view: EditorView) => void
}) {
  return [placeholderTheme, endlineDecoration(onClose)]
}
