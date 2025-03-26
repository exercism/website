import React, { ForwardedRef, forwardRef, useEffect, useState } from 'react'
import { Handler } from '@/components/misc/CodeMirror'
import { EditorState, Extension } from '@codemirror/state'
import { basicSetup, EditorView } from 'codemirror'
import { useLogger } from '../../common/hooks/useLogger'
import { onEditorChange } from './extensions/onEditorChange'

export const SimpleCodeMirror = forwardRef(function (
  {
    editorDidMount,
    style,
    onEditorChangeCallback,
    extensions = [],
    defaultCode = '',
  }: {
    editorDidMount: (handler: Handler) => void
    style?: React.CSSProperties
    onEditorChangeCallback?: (view: EditorView) => void
    defaultCode: string
    extensions?: Extension[]
  },
  ref: ForwardedRef<EditorView | null>
) {
  const [textarea, setTextarea] = useState<HTMLDivElement | null>(null)

  useLogger('editor did mount', editorDidMount)

  let value: string = defaultCode

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
    }
  })

  return (
    <div className="editor-wrapper" style={{ height: '100%', ...style }}>
      <div
        data-ci="codemirror-editor"
        id="bootcamp-cm-editor"
        className="editor"
        ref={setTextarea}
      />
    </div>
  )
})
