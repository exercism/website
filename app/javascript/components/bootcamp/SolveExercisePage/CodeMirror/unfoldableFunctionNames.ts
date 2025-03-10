import { StateField, StateEffect, Transaction } from '@codemirror/state'
import { EditorView } from 'codemirror'

// Define an Effect to Update the List
export const setUnfoldableFunctionsEffect = StateEffect.define<string[]>()

// Define the StateField to Store the List of Function Names
export const unfoldableFunctionsField = StateField.define<string[]>({
  // Initial value (example list of function names)
  create(): string[] {
    return []
  },

  // Update function for state changes
  update(value: string[], transaction: Transaction): string[] {
    const effect = transaction.effects.find((e) =>
      e.is(setUnfoldableFunctionsEffect)
    )
    const res = effect ? effect.value : value
    return res // Update if effect exists, else keep old value
  },
})

export const updateUnfoldableFunctions = (
  editorView: EditorView,
  names: string[]
) => {
  const tr = editorView.state.update({
    effects: [setUnfoldableFunctionsEffect.of(names)],
  })
  if (tr) editorView.dispatch(tr)
}
