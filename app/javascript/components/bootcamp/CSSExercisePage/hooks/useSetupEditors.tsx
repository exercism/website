import { useCallback } from 'react'
import { useLocalStorage } from '@uidotdev/usehooks'
import { useEditorHandler } from './useEditorHandler'

export function useSetupEditors(slug: string, code: CSSExercisePageCode) {
  const [editorCode, setEditorCode] = useLocalStorage(
    `css-editor-code-${slug}`,
    {
      htmlEditorContent: code.stub.html,
      cssEditorContent: code.stub.css,
      storedAt: new Date().toISOString(),
    }
  )

  if (
    // if there is no storedAt it means we have not submitted the code yet, ignore this, and keep using localStorage
    // localStorage defaults to the stub code.
    editorCode.storedAt &&
    code.storedAt &&
    // if the code on the server is newer than in localstorage, update the storage and load the code from the server
    // ---
    // code on the server must be newer by at least a minute
    new Date(editorCode.storedAt).getTime() <
      new Date(code.storedAt).getTime() - 60000
  ) {
    setEditorCode({
      // TODO: replace this to code.code once it's there
      htmlEditorContent: code.stub.html,
      cssEditorContent: code.stub.css,
      storedAt: code.storedAt,
    })
  }

  const {
    editorViewRef: htmlEditorViewRef,
    handleEditorDidMount: handleHtmlEditorDidMount,
  } = useEditorHandler(editorCode.htmlEditorContent)
  const {
    editorViewRef: cssEditorViewRef,
    handleEditorDidMount: handleCssEditorDidMount,
  } = useEditorHandler(editorCode.cssEditorContent)

  const resetEditors = useCallback(() => {
    const cssEditorView = cssEditorViewRef.current
    const htmlEditorView = htmlEditorViewRef.current

    if (!(cssEditorView && htmlEditorView)) return

    setEditorCode({
      htmlEditorContent: code.stub.html,
      cssEditorContent: code.stub.css,
      storedAt: new Date().toISOString(),
    })
    cssEditorView.dispatch({
      changes: {
        from: 0,
        to: cssEditorView.state.doc.length,
        insert: code.stub.css,
      },
    })

    htmlEditorView.dispatch({
      changes: {
        from: 0,
        to: htmlEditorView.state.doc.length,
        insert: code.stub.html,
      },
    })
  }, [])

  return {
    htmlEditorViewRef,
    cssEditorViewRef,
    resetEditors,
    handleHtmlEditorDidMount,
    handleCssEditorDidMount,
    setEditorCodeLocalStorage: setEditorCode,
  }
}
