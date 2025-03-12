import { Handler } from '@/components/misc/CodeMirror'
import { EditorView } from 'codemirror'
import { useRef } from 'react'

export function useEditorHandler(htmlDefaultValue: string) {
  const editorHandler = useRef<Handler | null>(null)
  const editorViewRef = useRef<EditorView | null>(null)

  const handleEditorDidMount = (handler: Handler) => {
    editorHandler.current = handler
    editorHandler.current.setValue(htmlDefaultValue)
  }

  return { editorHandler, editorViewRef, handleEditorDidMount }
}
