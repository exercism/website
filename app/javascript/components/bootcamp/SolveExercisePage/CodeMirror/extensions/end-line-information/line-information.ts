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
      for (const effect of tr.effects) {
        if (effect.is(informationWidgetDataEffect)) {
          return effect.value
        }
      }
      return value
    },
  })

function lineInformationWidget(view: EditorView): DecorationSet {
  let widgets: any[] = []

  const shouldShowWidget = view.state.field(showInfoWidgetField)
  const widgetData = view.state.field(informationWidgetDataField)

  // soft return
  if (widgetData.line === 0) return Decoration.none
  if (!shouldShowWidget) return Decoration.none

  const data = widgetData.html

  let deco = Decoration.widget({
    widget: new InformationWidget(data, widgetData.status),
    side: 1,
  })
  let lastPosOfLine = view.state.doc.line(widgetData.line).to

  widgets.push(deco.range(lastPosOfLine))

  return Decoration.set(widgets)
}

export const endLineDecoration = ViewPlugin.fromClass(
  class {
    placeholders: DecorationSet
    constructor(view: EditorView) {
      this.placeholders = lineInformationWidget(view)
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
        this.placeholders = lineInformationWidget(update.view)
      }
    }
  },
  {
    decorations: (instance) => instance.placeholders,
    provide: (plugin) =>
      EditorView.atomicRanges.of((view) => {
        return view.plugin(plugin)?.placeholders || Decoration.none
      }),
  }
)

export function lineInformationExtension() {
  return [placeholderTheme, endLineDecoration]
}
