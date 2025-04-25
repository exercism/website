import React from 'react'
import { EditorView } from '@codemirror/view'
import {
  addCodeToEndOfLine,
  removeLineContent,
  removeLine,
  highlightCodeSelection,
  removeAllHighlights,
  markLinesAsReadonly,
  revertLinesToEditable,
  typeOutCode,
  backspaceLines,
  deleteEditorContent,
  placeCursor,
  highlightEditorContent,
} from './utils'
import { showTutorTooltip } from './customCursor'
import { EditEditorActions } from './processActionsSequentially.types'

const processedUuids: string[] = []

export async function processActionsSequentially(
  viewRef: React.MutableRefObject<EditorView | null>,
  editEditorActions: EditEditorActions | undefined,
  uuid: string
): Promise<void> {
  if (
    !editEditorActions ||
    editEditorActions.actions.length === 0 ||
    processedUuids.includes(uuid)
  )
    return

  processedUuids.push(uuid)

  for (const action of editEditorActions.actions) {
    try {
      switch (action.type) {
        case 'type-out-code':
          await typeOutCode(viewRef.current!, action)
          break
        case 'remove-line':
          await removeLine(viewRef.current!, action)
          break
        case 'push-code':
          await addCodeToEndOfLine(viewRef.current!, action)
          break
        case 'remove-line-content':
          await removeLineContent(viewRef.current!, action)
          break
        case 'highlight-code':
          await highlightCodeSelection(viewRef.current!, action)
          break
        case 'remove-highlighting':
          await removeAllHighlights(viewRef.current!)
          break
        case 'mark-lines-as-readonly':
          await markLinesAsReadonly(viewRef.current!, action.ranges)
          break
        case 'revert-lines-to-editable':
          await revertLinesToEditable(viewRef.current!)
          break
        case 'backspace-lines':
          await backspaceLines(viewRef.current!, action)
          break
        case 'delete-editor-content':
          await deleteEditorContent(viewRef.current!)
          break
        case 'highlight-editor-content':
          await highlightEditorContent(viewRef.current!)
          break
        case 'place-cursor':
          await placeCursor(viewRef.current!, {
            line: action.line,
            char: action.char,
          })
          break
      }

      // fixed delay between actions?
      await new Promise((resolve) => setTimeout(resolve, 500))
    } catch (e) {
      console.error("Couldn't process things:", e)
    }
  }

  viewRef.current?.dispatch({ effects: showTutorTooltip.of(false) })
}

// actions examples

// const [id] = useState(uuid());
// const obj: EditEditorActions = {
//   uuid: id,
//   actions: [
// {
//   type: "type-out-code",
//   line: 4,
//   code: "// You can leave a comment like this",
// },
// { type: "remove-line-content", line: 4 },
// {
//   type: "type-out-code",
//   line: 4,
//   code: "// Now it's your turn.",
// },
// { type: "remove-line-content", line: 4 },
// { type: "highlight-code", from: 0, to: 10 },
// { type: "remove-highlighting" },
// {
//   type: "mark-lines-as-readonly",
//   ranges: [
//     { from: 1, to: 3 },
//     { from: 6, to: 6 },
//     { from: 11, to: 11 },
//   ],
// },
// {
//   type: "revert-lines-to-editable",
// },
//   ],
// };
