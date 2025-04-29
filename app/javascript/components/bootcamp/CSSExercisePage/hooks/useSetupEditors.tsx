import { useCallback, useEffect, RefObject, useState } from 'react'
import { useLocalStorage } from '@uidotdev/usehooks'
import { useEditorHandler } from './useEditorHandler'
import { updateIFrame } from '../utils/updateIFrame'
import { EditorView } from 'codemirror'
import { updateReadOnlyRangesEffect } from '../../JikiscriptExercisePage/CodeMirror/extensions/read-only-ranges/readOnlyRanges'

export function useSetupEditors(
  slug: string,
  code: CSSExercisePageCode,
  actualIFrameRef: RefObject<HTMLIFrameElement>
) {
  const [editorCodeIsReady, setEditorCodeIsReady] = useState(false)
  const [editorCode, setEditorCode] = useLocalStorage(
    `css-editor-code-${slug}`,
    getInitialEditorCode(code)
  )

  useEffect(() => {
    if (!!editorCode.storedAt) {
      setEditorCodeIsReady(true)
    }
  }, [editorCode.storedAt])

  const getEditorValues = useCallback(() => {
    const { cssEditorContent: cssValue, htmlEditorContent: htmlValue } =
      editorCode
    return { cssValue, htmlValue }
  }, [editorCode])

  // set it up once on mount
  useEffect(() => {
    updateIFrame(
      actualIFrameRef,
      {
        css: editorCode.cssEditorContent,
        html: editorCode.htmlEditorContent,
      },
      code
    )
  }, [])

  const {
    editorViewRef: htmlEditorViewRef,
    handleEditorDidMount: handleHtmlEditorDidMount,
  } = useEditorHandler(editorCode.htmlEditorContent, (view) => {
    if (!editorCodeIsReady) return
    if (shouldUpdateFromServer(editorCode.storedAt, code.storedAt)) {
      const { html, css } = JSON.parse(code.code)
      const codeFromServer = {
        htmlEditorContent: html,
        cssEditorContent: css,
        storedAt: code.storedAt!,
        readonlyRanges: {
          html: code.readonlyRanges?.html || [],
          css: code.readonlyRanges?.css || [],
        },
      }
      setEditorCode(codeFromServer)
      setupEditor(view, {
        code: html,
        readonlyRanges: codeFromServer.readonlyRanges.html,
      })
    } else {
      // otherwise we fallback to localstorage
      setupEditor(view, {
        code: editorCode?.htmlEditorContent || '',
        readonlyRanges: editorCode?.readonlyRanges?.html || [],
      })
    }
  })

  const {
    editorViewRef: cssEditorViewRef,
    handleEditorDidMount: handleCssEditorDidMount,
  } = useEditorHandler(editorCode.cssEditorContent, (view) => {
    if (!editorCodeIsReady) return
    if (shouldUpdateFromServer(editorCode.storedAt, code.storedAt)) {
      const { html, css } = JSON.parse(code.code)
      const newCode = {
        htmlEditorContent: html,
        cssEditorContent: css,
        storedAt: code.storedAt!,
        readonlyRanges: {
          html: code.readonlyRanges?.html || [],
          css: code.readonlyRanges?.css || [],
        },
      }
      setEditorCode(newCode)
      setupEditor(view, {
        code: css,
        readonlyRanges: newCode.readonlyRanges.css,
      })
    } else {
      setupEditor(view, {
        code: editorCode?.cssEditorContent || '',
        readonlyRanges: editorCode?.readonlyRanges?.css || [],
      })
    }
  })

  const resetEditors = useCallback(() => {
    const cssView = cssEditorViewRef.current
    const htmlView = htmlEditorViewRef.current

    if (!cssView || !htmlView) return

    setEditorCode({
      htmlEditorContent: code.stub.html,
      cssEditorContent: code.stub.css,
      storedAt: new Date().toISOString(),
      readonlyRanges: {
        html: code.defaultReadonlyRanges?.html || [],
        css: code.defaultReadonlyRanges?.css || [],
      },
    })

    resetSingleEditor(
      cssView,
      code.stub.css,
      code.defaultReadonlyRanges?.css || []
    )
    resetSingleEditor(
      htmlView,
      code.stub.html,
      code.defaultReadonlyRanges?.html || []
    )
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

function shouldUpdateFromServer(
  local?: string,
  server?: string | null
): boolean {
  return !!(
    local &&
    server &&
    // if local time is older than server time by more than 1 minute
    new Date(local).getTime() < new Date(server).getTime() - 60000
  )
}

function setupEditor(
  editorView: EditorView | null,
  {
    code,
    readonlyRanges,
  }: {
    code: string
    readonlyRanges?: { from: number; to: number }[]
  }
) {
  if (!editorView) return

  editorView.dispatch({
    changes: {
      from: 0,
      to: editorView.state.doc.length,
      insert: code,
    },
  })

  if (readonlyRanges) {
    editorView.dispatch({
      effects: updateReadOnlyRangesEffect.of(readonlyRanges),
    })
  }
}

function resetSingleEditor(
  view: EditorView | null,
  content: string,
  readonlyRanges: { from: number; to: number }[]
) {
  if (!view) return
  setupEditor(view, { code: '', readonlyRanges: [] })
  setupEditor(view, { code: content, readonlyRanges })
}

function getInitialEditorCode(code: CSSExercisePageCode) {
  let parsed: { html?: string; css?: string } = {}

  try {
    parsed = JSON.parse(code.code)
  } catch (err) {}

  const html =
    parsed.html && parsed.html.length > 0 ? parsed.html : code.stub.html
  const css = parsed.css && parsed.css.length > 0 ? parsed.css : code.stub.css

  return {
    htmlEditorContent: html,
    cssEditorContent: css,
    storedAt: new Date().toISOString(),
    readonlyRanges: {
      html: code.readonlyRanges?.html || [],
      css: code.readonlyRanges?.css || [],
    },
  }
}
