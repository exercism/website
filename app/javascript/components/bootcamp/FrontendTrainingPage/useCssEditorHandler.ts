import { Handler } from '@/components/misc/CodeMirror'
import { EditorView } from 'codemirror'
import { useRef } from 'react'

export function useCssEditorHandler() {
  const editorHandler = useRef<Handler | null>(null)
  const editorViewRef = useRef<EditorView | null>(null)

  const handleEditorDidMount = (handler: Handler) => {
    editorHandler.current = handler
  }

  return { editorHandler, editorViewRef, handleEditorDidMount }
}
