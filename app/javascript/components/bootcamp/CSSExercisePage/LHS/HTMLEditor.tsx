import React, { useContext, useMemo } from 'react'
import { html } from '@codemirror/lang-html'
import { CSSExercisePageContext } from '../CSSExercisePageContext'
import { htmlLinter } from '../SimpleCodeMirror/extensions/htmlLinter'
import { SimpleCodeMirror } from '../SimpleCodeMirror/SimpleCodeMirror'
import { useCSSExercisePageStore } from '../store/cssExercisePageStore'
import { EditorView } from 'codemirror'
import { debounce } from 'lodash'
import { readOnlyRangesStateField } from '../../JikiscriptExercisePage/CodeMirror/extensions/read-only-ranges/readOnlyRanges'
import { getCodeMirrorFieldValue } from '../../JikiscriptExercisePage/CodeMirror/getCodeMirrorFieldValue'

export function HTMLEditor() {
  const {
    handleHtmlEditorDidMount,
    htmlEditorRef,
    cssEditorRef,
    code,
    setEditorCodeLocalStorage,
  } = useContext(CSSExercisePageContext)
  const {
    panelSizes: { LHSWidth },
  } = useCSSExercisePageStore()

  const updateLocalStorageValueOnDebounce = useMemo(() => {
    return debounce((view: EditorView) => {
      if (!setEditorCodeLocalStorage) {
        return
      }

      const htmlReadonlyRanges = getCodeMirrorFieldValue(
        view,
        readOnlyRangesStateField
      )

      const cssReadonlyRanges = getCodeMirrorFieldValue(
        cssEditorRef.current,
        readOnlyRangesStateField
      )

      setEditorCodeLocalStorage({
        cssEditorContent: htmlEditorRef.current?.state.doc.toString() || '',
        htmlEditorContent: view.state.doc.toString(),
        storedAt: new Date().toISOString(),
        readonlyRanges: {
          css: cssReadonlyRanges,
          html: htmlReadonlyRanges,
        },
      })
    }, 500)
  }, [setEditorCodeLocalStorage, readOnlyRangesStateField])

  return (
    <SimpleCodeMirror
      style={{
        width: LHSWidth,
        height: '90vh',
        display: code.shouldHideHtmlEditor ? 'none' : 'block',
      }}
      ref={htmlEditorRef}
      editorDidMount={handleHtmlEditorDidMount}
      onEditorChangeCallback={(view) => {
        updateLocalStorageValueOnDebounce(view)
      }}
      extensions={[html(), htmlLinter]}
      defaultCode="<div>hello</div>"
    />
  )
}
