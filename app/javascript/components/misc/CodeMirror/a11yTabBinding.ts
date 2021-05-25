import { Text } from '@codemirror/text'
import { EditorView, KeyBinding } from '@codemirror/view'
import { Panel } from '@codemirror/panel'
import { insertTab, indentSelection } from '@codemirror/commands'
import { StateCommand } from '@codemirror/state'

export const a11yTabBindingPanelTheme = EditorView.baseTheme({
  '.cm-a11y-panel': {
    position: 'absolute',
    width: '1px',
    height: '1px',
    padding: '0',
    margin: '-1px',
    overflow: 'hidden',
    clip: 'rect(0, 0, 0, 0)',
    whiteSpace: 'nowrap',
    borderWidth: '0',
  },
})

export function a11yTabBindingPanel(view: EditorView): Panel {
  let dom = document.createElement('div')
  dom.textContent = ''
  console.log(dom)
  // @ts-ignore */
  dom.ariaLive = 'assertive'
  dom.className = 'cm-a11y-panel'

  return {
    top: true,
    dom,
    update(update) {
      if (!update.docChanged) {
        return
      }
      // @ts-ignore */
      if (update.changes.inserted.some((insert) => insert.text == '\t')) {
        dom.textContent = 'Press ESC then Tab to exit the editor'
        setTimeout(() => {
          dom.textContent = ''
        }, 5000)
      }
    },
  }
}

export const customInsertTab: StateCommand = ({ state, dispatch }) => {
  return insertTab({ state, dispatch })
}

export const a11yTabBinding: KeyBinding = {
  key: 'Tab',
  run: customInsertTab,
  shift: indentSelection,
}
