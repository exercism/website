import { useCallback, useEffect, RefObject, useState } from 'react'
import { useLocalStorage } from '@uidotdev/usehooks'
import { useEditorHandler } from './useEditorHandler'
import { updateIFrame } from '../utils/updateIFrame'
import { EditorView } from 'codemirror'
import { updateReadOnlyRangesEffect } from '../../JikiscriptExercisePage/CodeMirror/extensions/read-only-ranges/readOnlyRanges'
import { getInitialEditorCode } from './getInitialEditorCode'

export type ReadonlyRange = { from: number; to: number }

export type EditorCode = {
  htmlEditorContent: string
  cssEditorContent: string
  storedAt: string
  readonlyRanges: {
    html: ReadonlyRange[]
    css: ReadonlyRange[]
  }
}

export function useSetupEditors(
  slug: string,
  code: CSSExercisePageCode,
  actualIFrameRef: RefObject<HTMLIFrameElement>
) {
  const [editorCode, setEditorCode] = useLocalStorage<EditorCode>(
    `css-editor-code-${slug}`,
    getInitialEditorCode(code)
  )

  const [defaultCode] = useState<{ css: string; html: string }>({
    css: editorCode.cssEditorContent,
    html: editorCode.htmlEditorContent,
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

  const resetEditors = useCallback(() => {
    const cssView = cssEditorViewRef.current
    const htmlView = htmlEditorViewRef.current

    if (!cssView || !htmlView) return

    const stubEditorCode = {
      htmlEditorContent: code.stub.html,
      cssEditorContent: code.stub.css,
      storedAt: new Date().toISOString(),
      readonlyRanges: {
        html: code.defaultReadonlyRanges?.html || [],
        css: code.defaultReadonlyRanges?.css || [],
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
  }, [])

  return {
    htmlEditorViewRef,
    cssEditorViewRef,
    editorCode,
    defaultCode,
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
