import { useRef } from 'react'
import { EditorView } from 'codemirror'
import { Handler } from '@/components/misc/CodeMirror'

export function useEditorHandler(
  htmlDefaultValue: string,
  cbOnMount: (view: EditorView | null) => void
) {
  const editorHandler = useRef<Handler | null>(null)
  const editorViewRef = useRef<EditorView | null>(null)

  const handleEditorDidMount = (handler: Handler) => {
    editorHandler.current = handler
    editorHandler.current.setValue(htmlDefaultValue)

    cbOnMount(editorViewRef.current)
  }

  return { editorHandler, editorViewRef, handleEditorDidMount }
}
