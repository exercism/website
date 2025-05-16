import { readOnlyRangesStateField } from '@/components/bootcamp/JikiscriptExercisePage/CodeMirror/extensions/read-only-ranges/readOnlyRanges'
import { getCodeMirrorFieldValue } from '@/components/bootcamp/JikiscriptExercisePage/CodeMirror/getCodeMirrorFieldValue'
import { EditorView } from 'codemirror'
import { debounce } from 'lodash'

export function createUpdateLocalStorageValueOnDebounce() {
  return debounce(
    (
      editors: {
        cssEditor: EditorView | null
        htmlEditor: EditorView | null
        jsEditor: EditorView | null
      },
      setEditorCodeLocalStorage
    ) => {
      if (!setEditorCodeLocalStorage) {
        return
      }

      const htmlReadonlyRanges = getCodeMirrorFieldValue(
        editors.htmlEditor,
        readOnlyRangesStateField
      )

      const cssReadonlyRanges = getCodeMirrorFieldValue(
        editors.cssEditor,
        readOnlyRangesStateField
      )

      const jsReadonlyRanges = getCodeMirrorFieldValue(
        editors.jsEditor,
        readOnlyRangesStateField
      )

      setEditorCodeLocalStorage({
        cssEditorContent: editors.cssEditor?.state.doc.toString() || '',
        htmlEditorContent: editors.htmlEditor?.state.doc.toString() || '',
        jsEditorContent: editors.jsEditor?.state.doc.toString() || '',
        storedAt: new Date().toISOString(),
        readonlyRanges: {
          css: cssReadonlyRanges,
          html: htmlReadonlyRanges,
          js: jsReadonlyRanges,
        },
      })
    },
    500
  )
}
