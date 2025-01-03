import { EditorState, Transaction, type Extension } from '@codemirror/state'
import { EditorView } from '@codemirror/view'
import { getAvailableRanges } from 'range-analyzer'

export const smartDelete = (
  getReadOnlyRanges: (
    targetState: EditorState
  ) => Array<{ from: number | undefined; to: number | undefined }>
) =>
  EditorState.transactionFilter.of((tr: Transaction) => {
    if (
      tr.isUserEvent('delete.selection') &&
      !tr.isUserEvent('delete.selection.smart')
    ) {
      const initialSelections = tr.startState.selection.ranges.map((range) => ({
        from: range.from,
        to: range.to,
      }))

      if (initialSelections.length > 0) {
        const readOnlyRanges = getReadOnlyRanges(tr.startState)
        const result = getAvailableRanges(
          readOnlyRanges,
          initialSelections[0],
          {
            from: 0,
            to: tr.startState.doc.line(tr.startState.doc.lines).to,
          }
        ) as Array<{ from: number; to: number }>

        return result.map((range) =>
          tr.startState.update({
            changes: {
              from: range.from,
              to: range.to,
            },
            annotations: Transaction.userEvent.of(
              `${tr.annotation(Transaction.userEvent)}.smart`
            ),
          })
        )
      }
    }

    return tr
  })

export const preventModifyTargetRanges = (
  getReadOnlyRanges: (
    targetState: EditorState
  ) => Array<{ from: number | undefined; to: number | undefined }>
) =>
  EditorState.changeFilter.of((tr: Transaction) => {
    try {
      const readOnlyRangesBeforeTransaction = getReadOnlyRanges(tr.startState)
      const readOnlyRangesAfterTransaction = getReadOnlyRanges(tr.state)

      for (let i = 0; i < readOnlyRangesBeforeTransaction.length; i++) {
        const targetFromBeforeTransaction =
          readOnlyRangesBeforeTransaction[i].from ?? 0
        const targetToBeforeTransaction =
          readOnlyRangesBeforeTransaction[i].to ??
          tr.startState.doc.line(tr.startState.doc.lines).to

        const targetFromAfterTransaction =
          readOnlyRangesAfterTransaction[i].from ?? 0
        const targetToAfterTransaction =
          readOnlyRangesAfterTransaction[i].to ??
          tr.state.doc.line(tr.state.doc.lines).to

        if (
          tr.startState.sliceDoc(
            targetFromBeforeTransaction,
            targetToBeforeTransaction
          ) !==
          tr.state.sliceDoc(
            targetFromAfterTransaction,
            targetToAfterTransaction
          )
        ) {
          return false
        }
      }
    } catch (e) {
      return false
    }
    return true
  })

export const smartPaste = (
  getReadOnlyRanges: (
    targetState: EditorState
  ) => Array<{ from: number | undefined; to: number | undefined }>
) =>
  EditorView.domEventHandlers({
    paste(event, view) {
      const clipboardData = event.clipboardData || (window as any).clipboardData
      const pastedData = clipboardData.getData('Text')
      const initialSelections = view.state.selection.ranges.map((range) => ({
        from: range.from,
        to: range.to,
      }))

      if (initialSelections.length > 0) {
        const readOnlyRanges = getReadOnlyRanges(view.state)
        const result = getAvailableRanges(
          readOnlyRanges,
          initialSelections[0],
          {
            from: 0,
            to: view.state.doc.line(view.state.doc.lines).to,
          }
        ) as Array<{ from: number; to: number }>
        if (result.length > 0) {
          view.dispatch({
            changes: {
              from: result[0].from,
              to: result[0].to,
              insert: pastedData,
            },
            annotations: Transaction.userEvent.of(`input.paste.smart`),
          })
        }
      }
      return true
    },
  })

const readOnlyRangesExtension = (
  getReadOnlyRanges: (
    targetState: EditorState
  ) => Array<{ from: number | undefined; to: number | undefined }>
): Extension => [
  smartPaste(getReadOnlyRanges),
  smartDelete(getReadOnlyRanges),
  preventModifyTargetRanges(getReadOnlyRanges),
]
export default readOnlyRangesExtension
