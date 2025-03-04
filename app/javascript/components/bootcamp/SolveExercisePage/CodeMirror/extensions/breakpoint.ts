import { StateField, StateEffect, RangeSet } from '@codemirror/state'
import { EditorView, gutter, GutterMarker } from '@codemirror/view'

const breakpointEffect = StateEffect.define<{ pos: number; on: boolean }>({
  map: (val, mapping) => {
    return { pos: mapping.mapPos(val.pos), on: val.on }
  },
})

export const breakpointState = StateField.define<RangeSet<GutterMarker>>({
  create() {
    return RangeSet.empty
  },
  update(set, transaction) {
    set = set.map(transaction.changes)
    for (let e of transaction.effects) {
      if (e.is(breakpointEffect)) {
        if (e.value.on) {
          set = set.update({ add: [breakpointMarker.range(e.value.pos)] })
        } else {
          set = set.update({ filter: (from) => from != e.value.pos })
        }
      }
    }
    return set
  },
})

function toggleBreakpoint(view: EditorView, pos: number) {
  let breakpoints = view.state.field(breakpointState)
  console.log('breakpoints', breakpoints)
  let hasBreakpoint = false
  breakpoints.between(pos, pos, () => {
    hasBreakpoint = true
  })
  view.dispatch({
    effects: breakpointEffect.of({ pos, on: !hasBreakpoint }),
  })
}

const breakpointMarker = new (class extends GutterMarker {
  toDOM() {
    const dot = document.createElement('div')
    Object.assign(dot.style, {})
    dot.classList.add('cm-breakpoint-marker')
    dot.title = 'Remove breakpoint'

    return dot
  }
})()

class IdleMarker extends GutterMarker {
  toDOM() {
    const dot = document.createElement('div')
    dot.classList.add('cm-idle-marker')
    dot.title = 'Add breakpoint'
    return dot
  }
}

const idleMarker = new IdleMarker()
export const breakpointGutter = [
  breakpointState,
  gutter({
    class: 'cm-breakpoint-gutter',
    markers: (view) => {
      const breakpoints = view.state.field(breakpointState)
      const markers: any[] = []

      for (let i = 1; i <= view.state.doc.lines; i++) {
        const pos = view.state.doc.line(i).from
        let hasBreakpoint = false

        breakpoints.between(pos, pos, (from) => {
          if (from === pos) hasBreakpoint = true
        })

        markers.push((hasBreakpoint ? breakpointMarker : idleMarker).range(pos))
      }

      return RangeSet.of(markers)
    },
    initialSpacer: () => breakpointMarker,
    domEventHandlers: {
      mousedown(view, line) {
        toggleBreakpoint(view, line.from)
        return true
      },
    },
  }),
  EditorView.baseTheme({
    '.cm-breakpoint-gutter .cm-gutterElement': {
      display: 'grid',
      placeContent: 'center',
    },
  }),
]
