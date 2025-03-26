import React, { ForwardedRef, forwardRef, useEffect, useState } from 'react'
import { Handler } from '@/components/misc/CodeMirror'
import { EditorState, Extension } from '@codemirror/state'
import { basicSetup, EditorView } from 'codemirror'
import { onEditorChange } from './extensions/onEditorChange'

export const SimpleCodeMirror = forwardRef(function (
  {
    editorDidMount,
    style,
    onEditorChangeCallback,
    extensions = [],
  }: {
    editorDidMount: (handler: Handler) => void
    style?: React.CSSProperties
    onEditorChangeCallback?: (view: EditorView) => void
    extensions?: Extension[]
  },
  ref: ForwardedRef<EditorView | null>
) {
  const [textarea, setTextarea] = useState<HTMLDivElement | null>(null)

  let value: string

  const getEditorView = (): EditorView | null => {
    if (typeof ref === 'function') {
      throw new Error('Callback refs are not supported.')
    }
    if (ref === null) return null
    return ref.current
  }

  const setValue = (text: string) => {
    const editorView = getEditorView()
    if (!editorView) {
      return
    }

    const transaction = editorView.state.update({
      changes: {
        from: 0,
        to: editorView.state.doc.length,
        insert: text,
      },
    })

    editorView.dispatch(transaction)
  }

  const getValue = () => {
    const editorView = getEditorView()
    return (value = editorView?.state.doc.toString() || '')
  }

  useEffect(() => {
    if (!textarea || getEditorView()) {
      return
    }

    const view = new EditorView({
      state: EditorState.create({
        doc: value,
        extensions: [
          basicSetup,
          onEditorChange(() => {
            if (onEditorChangeCallback) {
              onEditorChangeCallback(view)
            }
          }),
          ...extensions,
        ],
      }),
      parent: textarea,
    })

    if (typeof ref === 'function') {
      throw new Error('Callback refs are not supported.')
    } else if (ref) {
      ref.current = view
    }

    try {
      editorDidMount({ setValue, getValue, focus: view.focus.bind(view) })
    } catch (e: unknown) {
      if (
        process.env.NODE_ENV === 'development' ||
        process.env.NODE_ENV === 'test'
      ) {
        throw e
      }

      // setHasUnhandledError(true)
      // setUnhandledErrorBase64(
      //   JSON.stringify({
      //     error: String(e),
      //     code: value,
      //     type: 'Codemirror editor mounting',
      //   })
      // )
    }
  }, [])

  return (
    <div className="editor-wrapper" style={style}>
      <div
        data-ci="codemirror-editor"
        id="bootcamp-cm-editor"
        className="editor"
        ref={setTextarea}
      />
    </div>
  )
})
