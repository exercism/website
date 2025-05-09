import { useCallback, useEffect, RefObject, useState } from 'react'
import { useLocalStorage } from '@uidotdev/usehooks'
import { useEditorHandler } from '../../common/hooks/useEditorHandler'
import { updateIFrame } from '../utils/updateIFrame'
import { EditorView } from 'codemirror'
import { updateReadOnlyRangesEffect } from '../../JikiscriptExercisePage/CodeMirror/extensions/read-only-ranges/readOnlyRanges'

export type ReadonlyRange = { from: number; to: number }

export type FrontendEditorCode = {
  htmlEditorContent: string
  cssEditorContent: string
  jsEditorContent: string
  storedAt: string
  readonlyRanges: {
    html: ReadonlyRange[]
    css: ReadonlyRange[]
    js: ReadonlyRange[]
  }
}

export function useSetupEditors(
  slug: string,
  code: FrontendExercisePageCode,
  actualIFrameRef: RefObject<HTMLIFrameElement>
) {
  const [editorCode, setEditorCode] = useLocalStorage<FrontendEditorCode>(
    `frontend-editor-code-${slug}`,
    getInitialEditorCode(code)
  )

  const [defaultCode] = useState<{ css: string; html: string; js: string }>({
    css: editorCode.cssEditorContent,
    html: editorCode.htmlEditorContent,
    js: editorCode.jsEditorContent,
  })

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
    if (shouldUpdateFromServer(editorCode.storedAt, code.storedAt)) {
      try {
        const { html, css, js } = JSON.parse(code.code)

        const codeFromServer = {
          htmlEditorContent: html,
          cssEditorContent: css,
          jsEditorContent: js,
          storedAt: code.storedAt!,
          readonlyRanges: {
            html: code.readonlyRanges?.html || [],
            css: code.readonlyRanges?.css || [],
            js: code.readonlyRanges?.js || [],
          },
        }

        setEditorCode(codeFromServer)
        setupEditor(view, {
          code: html,
          readonlyRanges: codeFromServer.readonlyRanges.html,
        })
      } catch (error) {
        console.error('Error updating from server:', error)
        // on error fallback to existing data
        setupEditor(view, {
          code: editorCode.htmlEditorContent,
          readonlyRanges: editorCode.readonlyRanges?.html,
        })
      }
    } else {
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
    if (shouldUpdateFromServer(editorCode.storedAt, code.storedAt)) {
      try {
        const { html, css, js } = JSON.parse(code.code)

        const newCode = {
          htmlEditorContent: html,
          cssEditorContent: css,
          jsEditorContent: js,
          storedAt: code.storedAt!,
          readonlyRanges: {
            html: code.readonlyRanges?.html || [],
            css: code.readonlyRanges?.css || [],
            js: code.readonlyRanges?.js || [],
          },
        }

        setEditorCode(newCode)
        setupEditor(view, {
          code: css,
          readonlyRanges: newCode.readonlyRanges.css,
        })
      } catch (error) {
        console.error('Error updating from server:', error)

        setupEditor(view, {
          code: editorCode.cssEditorContent,
          readonlyRanges: editorCode.readonlyRanges?.css,
        })
      }
    } else {
      setupEditor(view, {
        code: editorCode.cssEditorContent,
        readonlyRanges: editorCode.readonlyRanges?.css || [],
      })
    }
  })

  const {
    editorViewRef: jsEditorViewRef,
    handleEditorDidMount: handleJsEditorDidMount,
  } = useEditorHandler(editorCode.jsEditorContent, (view) => {
    if (shouldUpdateFromServer(editorCode.storedAt, code.storedAt)) {
      try {
        const { html, css, js } = JSON.parse(code.code)

        const newCode = {
          htmlEditorContent: html,
          cssEditorContent: css,
          jsEditorContent: js,
          storedAt: code.storedAt!,
          readonlyRanges: {
            html: code.readonlyRanges?.html || [],
            css: code.readonlyRanges?.css || [],
            js: code.readonlyRanges?.js || [],
          },
        }

        setEditorCode(newCode)
        setupEditor(view, {
          code: js,
          readonlyRanges: newCode.readonlyRanges.js,
        })
      } catch (error) {
        console.error('Error updating from server:', error)

        setupEditor(view, {
          code: editorCode.jsEditorContent,
          readonlyRanges: editorCode.readonlyRanges?.js,
        })
      }
    } else {
      setupEditor(view, {
        code: editorCode.jsEditorContent,
        readonlyRanges: editorCode.readonlyRanges?.js || [],
      })
    }
  })

  const resetEditors = useCallback(() => {
    const cssView = cssEditorViewRef.current
    const htmlView = htmlEditorViewRef.current
    const jsView = jsEditorViewRef.current

    if (!cssView || !htmlView || !jsView) return

    const stubEditorCode = {
      htmlEditorContent: code.stub.html,
      cssEditorContent: code.stub.css,
      jsEditorContent: code.stub.js,
      storedAt: new Date().toISOString(),
      readonlyRanges: {
        html: code.defaultReadonlyRanges?.html || [],
        css: code.defaultReadonlyRanges?.css || [],
        js: code.defaultReadonlyRanges?.js || [],
      },
    }

    setEditorCode(stubEditorCode)

    resetSingleEditor(
      cssView,
      stubEditorCode.cssEditorContent,
      stubEditorCode.readonlyRanges.css
    )
    resetSingleEditor(
      htmlView,
      stubEditorCode.htmlEditorContent,
      stubEditorCode.readonlyRanges.html
    )
    resetSingleEditor(
      jsView,
      stubEditorCode.jsEditorContent,
      stubEditorCode.readonlyRanges.js
    )
  }, [])

  return {
    htmlEditorViewRef,
    cssEditorViewRef,
    jsEditorViewRef,
    editorCode,
    defaultCode,
    resetEditors,
    handleHtmlEditorDidMount,
    handleCssEditorDidMount,
    handleJsEditorDidMount,
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
    readonlyRanges?: ReadonlyRange[]
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

  if (!readonlyRanges) return
  editorView.dispatch({
    effects: updateReadOnlyRangesEffect.of(readonlyRanges),
  })
}

function resetSingleEditor(
  view: EditorView | null,
  content: string,
  readonlyRanges: ReadonlyRange[]
) {
  if (!view) return
  setupEditor(view, { code: '', readonlyRanges: [] })
  setupEditor(view, { code: content, readonlyRanges })
}

function getInitialEditorCode(
  code: FrontendExercisePageCode
): FrontendEditorCode {
  const fallbackReadonlyRanges = {
    html: code.defaultReadonlyRanges?.html || [],
    css: code.defaultReadonlyRanges?.css || [],
    js: code.defaultReadonlyRanges?.js || [],
  }

  const fallbackCode: FrontendEditorCode = {
    htmlEditorContent: code.stub.html,
    cssEditorContent: code.stub.css,
    jsEditorContent: code.stub.js,
    storedAt: new Date().toISOString(),
    readonlyRanges: fallbackReadonlyRanges,
  }

  if (!code.code) return fallbackCode

  let parsed: { html?: string; css?: string; js?: string }
  try {
    parsed = JSON.parse(code.code)
  } catch (error) {
    console.error('Error parsing initial code:', error)
    return fallbackCode
  }

  const html = parsed.html?.trim() || code.stub.html
  const css = parsed.css?.trim() || code.stub.css
  const js = parsed.js?.trim() || code.stub.js
  return {
    htmlEditorContent: html,
    cssEditorContent: css,
    jsEditorContent: js,
    storedAt: new Date().toISOString(),
    readonlyRanges: {
      html: code.readonlyRanges?.html || [],
      css: code.readonlyRanges?.css || [],
      js: code.readonlyRanges?.js || [],
    },
  }
}
