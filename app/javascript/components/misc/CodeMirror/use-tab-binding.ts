import { KeyBinding } from '@codemirror/view'
import { StateCommand, Transaction } from '@codemirror/state'
import { indentMore, indentSelection } from '@codemirror/commands'

export const useTabBinding = (
  indentChar: string,
  useSoftTabs: boolean
): KeyBinding => {
  const toInsert = useSoftTabs ? indentChar : '\t'

  const insertTab: StateCommand = ({ state, dispatch }) => {
    if (state.selection.ranges.some((r) => !r.empty))
      return indentMore({ state, dispatch })
    dispatch(
      state.update(state.replaceSelection(toInsert), {
        scrollIntoView: true,
        annotations: Transaction.userEvent.of('input'),
      })
    )
    return true
  }

  const tabBinding: KeyBinding = {
    key: 'Tab',
    run: insertTab,
    shift: indentSelection,
  }

  return tabBinding
}
