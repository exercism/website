import { useCallback, useEffect } from 'react'
import { useLocalStorage } from '@uidotdev/usehooks'
import { useEditorHandler } from './useEditorHandler'
import { updateIFrame } from '../utils/updateIFrame'
import { EditorView } from 'codemirror'
import { updateReadOnlyRangesEffect } from '../../JikiscriptExercisePage/CodeMirror/extensions/read-only-ranges/readOnlyRanges'

export function useSetupEditors(
  slug: string,
  code: CSSExercisePageCode,
  actualIFrameRef: React.RefObject<HTMLIFrameElement>
) {
  const [editorCode, setEditorCode] = useLocalStorage(
    `css-editor-code-${slug}`,
    {
      htmlEditorContent: code.stub.html,
      cssEditorContent: code.stub.css,
      storedAt: new Date().toISOString(),
      readonlyRanges: {
        html: code.readonlyRanges?.html || [],
        css: code.readonlyRanges?.css || [],
      },
    }
  )

  const getEditorValues = useCallback(() => {
    const { cssEditorContent: cssValue, htmlEditorContent: htmlValue } =
      editorCode
    return { cssValue, htmlValue }
  }, [editorCode])

  useEffect(() => {
    updateIFrame(
      actualIFrameRef,
      {
        css: editorCode.cssEditorContent,
        html: editorCode.htmlEditorContent,
      },
      code.default
    )
  }, [editorCode.cssEditorContent, editorCode.htmlEditorContent])

  const {
    editorViewRef: htmlEditorViewRef,
    handleEditorDidMount: handleHtmlEditorDidMount,
  } = useEditorHandler(editorCode.htmlEditorContent, (view) => {
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
      // Might be a weak point
      // TODO: Add extra guard here
      const { html, css } = JSON.parse(code.code)
      setEditorCode({
        htmlEditorContent: html,
        cssEditorContent: css,
        storedAt: code.storedAt,
        readonlyRanges: {
          html: code.readonlyRanges?.html || [],
          css: code.readonlyRanges?.css || [],
        },
      })
      // setupReadonlyRanges(view, code.readonlyRanges?.html || [])
      setupEditor(view, {
        code: html,
        readonlyRanges: code.readonlyRanges?.html || [],
      })
    } else {
      // we don't need to set editor code here, because that defaults to the stub code
      setupEditor(view, {
        code: editorCode.htmlEditorContent,
        readonlyRanges: editorCode.readonlyRanges?.html || [],
      })
    }
  })
  const {
    editorViewRef: cssEditorViewRef,
    handleEditorDidMount: handleCssEditorDidMount,
  } = useEditorHandler(editorCode.cssEditorContent, (view) => {
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
      // Might be a weak point
      // TODO: Add extra guard here
      const { html, css } = JSON.parse(code.code)
      setEditorCode({
        htmlEditorContent: html,
        cssEditorContent: css,
        storedAt: code.storedAt,
        readonlyRanges: {
          html: code.readonlyRanges?.html || [],
          css: code.readonlyRanges?.css || [],
        },
      })
      setupEditor(view, {
        code: css,
        readonlyRanges: code.readonlyRanges?.css || [],
      })
    } else {
      // we don't need to set editor code here, because that defaults to the stub code
      setupEditor(view, {
        code: editorCode.cssEditorContent,
        readonlyRanges: editorCode.readonlyRanges?.css || [],
      })
    }
  })

  const resetEditors = useCallback(() => {
    const cssEditorView = cssEditorViewRef.current
    const htmlEditorView = htmlEditorViewRef.current

    if (!(cssEditorView && htmlEditorView)) return

    setEditorCode({
      htmlEditorContent: code.stub.html,
      cssEditorContent: code.stub.css,
      storedAt: new Date().toISOString(),
      readonlyRanges: {
        html: code.defaultReadonlyRanges?.html || [],
        css: code.defaultReadonlyRanges?.css || [],
      },
    })

    // reset first
    setupEditor(cssEditorView, {
      code: '',
      readonlyRanges: [],
    })

    setupEditor(cssEditorView, {
      code: code.stub.css,
      readonlyRanges: code.defaultReadonlyRanges?.css || [],
    })

    setupEditor(htmlEditorView, {
      code: '',
      readonlyRanges: [],
    })

    setupEditor(htmlEditorView, {
      code: code.stub.html,
      readonlyRanges: code.defaultReadonlyRanges?.html || [],
    })
  }, [])

  return {
    htmlEditorViewRef,
    cssEditorViewRef,
    resetEditors,
    handleHtmlEditorDidMount,
    handleCssEditorDidMount,
    setEditorCodeLocalStorage: setEditorCode,
    getEditorValues,
  }
}

function setupReadonlyRanges(
  editorView: EditorView | null,
  readonlyRanges: { from: number; to: number }[]
) {
  if (!editorView) return

  if (readonlyRanges) {
    editorView.dispatch({
      effects: updateReadOnlyRangesEffect.of(readonlyRanges),
    })
  }
}

function setupEditor(
  editorView: EditorView | null,
  {
    readonlyRanges,
    code,
  }: { readonlyRanges?: { from: number; to: number }[]; code: string }
) {
  if (!editorView) return

  // This needs to happen before the code is added.

  if (code) {
    editorView.dispatch({
      changes: {
        from: 0,
        to: editorView.state.doc.length,
        insert: code,
      },
    })
  }
  if (readonlyRanges) {
    editorView.dispatch({
      effects: updateReadOnlyRangesEffect.of(readonlyRanges),
    })
  }
}
