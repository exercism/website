import { EditorView, type Tooltip, showTooltip } from '@codemirror/view'
import { EditorState, StateEffect, StateField } from '@codemirror/state'

export const showTutorTooltip = StateEffect.define<boolean>()
interface TooltipState {
  visible: boolean
  tooltips: readonly Tooltip[]
}

export const cursorTooltipField = StateField.define<TooltipState>({
  create(state) {
    return { visible: false, tooltips: getCursorTooltips(state) }
  },

  update(value, tr) {
    let showTutorEffect = tr.effects.find((e) => e.is(showTutorTooltip))
    const newTooltip = { ...value }

    if (showTutorEffect !== undefined) {
      newTooltip.visible = showTutorEffect.value
    }

    if (newTooltip.visible || tr.docChanged || tr.selection) {
      newTooltip.tooltips = getCursorTooltips(tr.state)
    } else {
      newTooltip.tooltips = []
    }

    return newTooltip
  },

  provide: (f) =>
    showTooltip.computeN([f], (state) => {
      const { visible, tooltips } = state.field(f)
      return visible ? tooltips : []
    }),
})

function getCursorTooltips(state: EditorState): readonly Tooltip[] {
  return state.selection.ranges
    .filter((range) => range.empty)
    .map((range) => {
      return {
        pos: range.head,
        above: true,
        strictSide: false,
        arrow: true,
        create: () => {
          let dom = document.createElement('div')
          dom.innerHTML = `
          <img src="src/assets/robot.png" width='50' height='50' class='rounded-8'>
          `
          dom.className = 'cm-tooltip-cursor'
          return { dom }
        },
      }
    })
}

const cursorTooltipBaseTheme = EditorView.baseTheme({
  '.cm-tooltip.cm-tooltip-cursor': {
    background: '#4B8C9C',
    padding: '2px',
    borderRadius: '8px',
    '& .cm-tooltip-arrow:before': {
      borderTopColor: '#4B8C9C',
    },
    '& .cm-tooltip-arrow:after': {
      borderTopColor: 'transparent',
    },
  },
})

export function cursorTooltip() {
  return [cursorTooltipField, cursorTooltipBaseTheme]
}
