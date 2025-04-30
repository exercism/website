import React, {
  ForwardedRef,
  forwardRef,
  useEffect,
  useRef,
  useState,
} from 'react'
import { Handler } from '@/components/misc/CodeMirror'
import { EditorState, Extension } from '@codemirror/state'
import { basicSetup, EditorView } from 'codemirror'
import { onEditorChange } from './extensions/onEditorChange'
import { keymap } from '@codemirror/view'
import { indentWithTab } from '@codemirror/commands'
import { defaultKeymap, historyKeymap } from '@codemirror/commands'

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
    defaultCode?: string
    extensions?: Extension[]
  },
  ref: ForwardedRef<EditorView | null>
) {
  const [textarea, setTextarea] = useState<HTMLDivElement | null>(null)

  const value = useRef(defaultCode)

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
    return (value.current = editorView?.state.doc.toString() || '')
  }

  const initializedRef = useRef(false)

  useEffect(() => {
    if (!textarea || initializedRef.current) return

    const view = new EditorView({
      state: EditorState.create({
        doc: value.current,
        extensions: [
          basicSetup,
          keymap.of([...defaultKeymap, ...historyKeymap, indentWithTab]),
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

    if (typeof ref !== 'function' && ref) {
      ref.current = view
    }

    editorDidMount({
      setValue,
      getValue,
      focus: view.focus.bind(view),
    })

    initializedRef.current = true

    return () => {
      initializedRef.current = false
      view.destroy()
      if (ref && typeof ref !== 'function') {
        ref.current = null
      }
    }
  }, [textarea])

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
