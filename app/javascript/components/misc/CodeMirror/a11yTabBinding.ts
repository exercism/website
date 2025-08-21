import { EditorView, Panel, showPanel } from '@codemirror/view'
import { StateField } from '@codemirror/state'

// See the note on this near the bottom of the file
// import { insertTab, indentSelection } from '@codemirror/commands'
// import { KeyBinding } from '@codemirror/view'
// import { StateCommand } from '@codemirror/state'

// This is taken from Tailwind's `sr-only` class.
// It hides the panel from view on visual devices
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

// The typing for this seems to be wrong in CodeMirror.
// Changes doesn't have `inserted` defined on it
function tabPressed(changes: any): boolean {
  // @ts-ignore */
  return changes.inserted.some((insert) => insert.text == '\t')
}

// This cycles though the desired value every time tab is pressed.
// This is useful for ensuring that screen-readers don't just
// think the text is the same as it previously was and ignore it.
//
// Currently this cycles whenever tab is pressed, whether or not we announce
// it via the aria-live region (ie whether the box is blank or not at the time)
// We may want to change this but I've not yet worked out how.
//
// Announcements only seem to happen once per prompt however many
// times it is cycled into the box (I presume that's a non-spamming feature)
// so for now I have 5 different prompts which means this is announced a maximum
// of 5 times. There's also a chance this is just down to something weird
// in VoiceOver (which seems to be quite random to me) so this might be entirelty
// unncessary and we can just switch between twodifferent ones as per a previous
// commit in the PR that adds this.
const prompts = [
  'Press Escape then Tab to exit the editor',
  'To exit the editor, press Escape then tab',
  'Press Escape followed by tab to exit the editor',
  'If you want to exit the editor, press Escape then Tab',
  'In order to exit the editor, press Escape then Tab',
]
const a11yTabBindingState = StateField.define<string>({
  create: () => '',
  update(value, tr) {
    if (!tabPressed(tr.changes)) {
      return value
    }
    let found = false
    const newValue = prompts.find((prompt) => {
      if (found) {
        return value
      }

      if (value == prompt) {
        found = true
      }
    })
    value = newValue || prompts[0]
    return value
  },
})

// This creates a CodeMirror Panel, adds its classes and sets it
// to be an assertive ariaLive area. It is assertive as it only
// changes in direct response to a user pressing the tab key.
function createA11yTabBindingPanel(view: EditorView): Panel {
  const dom = document.createElement('div')
  dom.textContent = ''
  dom.className = 'cm-a11y-panel'

  dom.setAttribute('aria-live', 'assertive')
  dom.setAttribute('aria-atomic', 'true')

  return {
    top: true,
    dom,
    update(update) {
      // Only announce things if the user has pressed a tab
      if (!update.docChanged || !tabPressed(update.changes)) {
        return
      }

      // Only announce things if the aria-live area has been reset
      if (dom.textContent != '') {
        return
      }

      // Set the text content, which announces via the aria-live functionality.
      dom.textContent = view.state.field(a11yTabBindingState)

      // Reset the text content five seconds later.
      setTimeout(() => {
        dom.textContent = ''
      }, 5000)
    },
  }
}

// We may want to add an update manually here so that we are relying
// on the fact someone has pressed the tab key, not somehow inserted
// a tab a different way. However, that's one step too far for this
// initial version as it would involve dispatching custom events.
//
// const customInsertTab: StateCommand = ({ state, dispatch }) => {
//   return insertTab({ state, dispatch })
// }
// const customIntendSelection: Command = (target) => {
//   return indentSelection(target)
// }
// const a11yTabBinding: KeyBinding = {
//   key: 'Tab',
//   run: customInsertTab,
//   shift: indentSelection,
// }

// Add all the parts together in one function that is exported
// and added to the CodeMirror configuration
export function a11yTabBindingPanel() {
  return [
    a11yTabBindingState,
    showPanel.of(createA11yTabBindingPanel),
    a11yTabBindingPanelTheme,

    // We'll ideally add this here too, but currently it's needed
    // for when the editor gets reconfigured downstream of this.
    // tabCaptureCompartment.of( keymap.of(isTabCaptured ? [a11yTabBinding] : [])),
  ]
}
