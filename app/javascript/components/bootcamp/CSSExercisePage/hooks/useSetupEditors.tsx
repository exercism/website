import { useCallback, useEffect, useRef } from 'react'
import { useLocalStorage } from '@uidotdev/usehooks'
import { updateIFrame } from '../utils/updateIFrame'
import { EditorView } from 'codemirror'
import { updateReadOnlyRangesEffect } from '../../JikiscriptExercisePage/CodeMirror/extensions/read-only-ranges/readOnlyRanges'
import { Handler } from '@/components/misc/CodeMirror'
import { useLogger } from '@/hooks'

export function useSetupEditors(
  slug: string,
  code: CSSExercisePageCode,
  actualIFrameRef: React.RefObject<HTMLIFrameElement>
) {
  const [editorCode, setEditorCode] = useLocalStorage<{
    htmlEditorContent: string
    cssEditorContent: string
    readonlyRanges: {
      html?: ReadonlyRange[]
      css?: ReadonlyRange[]
    }
    storedAt: string
  }>(`css-editor-code-${slug}`, {
    htmlEditorContent: code.stub.html,
    cssEditorContent: code.stub.css,
    readonlyRanges: {
      css: code.defaultReadonlyRanges?.css,
      html: code.defaultReadonlyRanges?.html,
    },
    storedAt: new Date().toISOString(),
  })

  useLogger('defaultreadonlyranges', {
    css: code.defaultReadonlyRanges?.css,
  })

  const htmlEditorHandler = useRef<Handler | null>(null)
  const htmlEditorViewRef = useRef<EditorView | null>(null)

  const handleHtmlEditorDidMount = (handler: Handler) => {
    htmlEditorHandler.current = handler
    htmlEditorHandler.current.setValue(editorCode.htmlEditorContent)
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
        readonlyRanges: {
          css: code.defaultReadonlyRanges?.css,
          html: code.defaultReadonlyRanges?.html,
        },
        storedAt: code.storedAt,
      })

      setupEditor(htmlEditorViewRef.current, {
        code: html,
        readonlyRanges: code.defaultReadonlyRanges?.html,
      })
    } else {
      // if the code on the server is not newer, use the code from localStorage
      // and set the readonly ranges
      setupEditor(htmlEditorViewRef.current, {
        code: editorCode.htmlEditorContent,
        readonlyRanges: editorCode.readonlyRanges?.html,
      })
    }
  }

  const cssEditorHandler = useRef<Handler | null>(null)
  const cssEditorViewRef = useRef<EditorView | null>(null)

  const handleCssEditorDidMount = (handler: Handler) => {
    cssEditorHandler.current = handler
    cssEditorHandler.current.setValue(editorCode.cssEditorContent)
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
        readonlyRanges: {
          css: code.defaultReadonlyRanges?.css,
          html: code.defaultReadonlyRanges?.html,
        },
        storedAt: code.storedAt,
      })

      setupEditor(cssEditorViewRef.current, {
        code: css,
        readonlyRanges: code.defaultReadonlyRanges?.css,
      })
    } else {
      // if the code on the server is not newer, use the code from localStorage
      // and set the readonly ranges
      setupEditor(cssEditorViewRef.current, {
        code: editorCode.cssEditorContent,
        readonlyRanges: editorCode.readonlyRanges?.css,
      })
    }
  }

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

  const resetEditors = useCallback(() => {
    const cssEditorView = cssEditorViewRef.current
    const htmlEditorView = htmlEditorViewRef.current

    if (!(cssEditorView && htmlEditorView)) return

    setEditorCode({
      htmlEditorContent: code.stub.html,
      cssEditorContent: code.stub.css,
      readonlyRanges: {
        css: code.defaultReadonlyRanges?.css,
        html: code.defaultReadonlyRanges?.html,
      },
      storedAt: new Date().toISOString(),
    })

    setupEditor(htmlEditorView, {
      code: '',
      readonlyRanges: [],
    })
    setupEditor(cssEditorView, {
      code: '',
      readonlyRanges: [],
    })

    setupEditor(htmlEditorView, {
      code: code.stub.html,
      readonlyRanges: code.defaultReadonlyRanges?.html,
    })
    setupEditor(cssEditorView, {
      code: code.stub.css,
      readonlyRanges: code.defaultReadonlyRanges?.css,
    })
  }, [setEditorCode])

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

function setupEditor(
  editorView: EditorView | null,
  {
    readonlyRanges,
    code,
  }: { readonlyRanges?: { from: number; to: number }[]; code: string }
) {
  if (!editorView) return

  if (code) {
    editorView.dispatch({
      changes: {
        from: 0,
        to: editorView.state.doc.length,
        insert: code,
      },
    })
  }

  console.log('READONLY', readonlyRanges)
  if (readonlyRanges) {
    editorView.dispatch({
      effects: updateReadOnlyRangesEffect.of(readonlyRanges),
    })
  }
}
