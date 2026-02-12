import { EditorView } from 'codemirror'

export const moveCursorByPasteLength = EditorView.domEventHandlers({
  paste: (event, view) => {
    const pastedText = event.clipboardData?.getData('text')
    if (!pastedText) return false

    // make sure things happen after the paste
    setTimeout(() => {
      const { from } = view.state.selection.main
      const pastedLength = pastedText.length

      view.dispatch({
        selection: {
          anchor: Math.min(from + pastedLength, view.state.doc.length),
        },
        scrollIntoView: true,
      })
    }, 0)

    return false
  },
})
