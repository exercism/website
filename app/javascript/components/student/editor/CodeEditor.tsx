import React, { useRef } from 'react'
import MonacoEditor from 'react-monaco-editor'
import * as monacoEditor from 'monaco-editor/esm/vs/editor/editor.api'

export function CodeEditor({ onSubmit }: { onSubmit: (code: string) => void }) {
  const editorRef = useRef<monacoEditor.editor.IStandaloneCodeEditor>()

  function handleSubmit(e: React.MouseEvent<HTMLButtonElement>) {
    e.preventDefault()

    onSubmit(editorRef.current?.getValue() || '')
  }

  function editorDidMount(
    editor: monacoEditor.editor.IStandaloneCodeEditor,
    monaco: typeof monacoEditor
  ) {
    editorRef.current = editor
  }

  return (
    <div>
      <MonacoEditor
        width="800"
        height="600"
        language="ruby"
        editorDidMount={editorDidMount}
        value="Code"
      />
      <button type="button" onClick={handleSubmit}>
        Run tests
      </button>
    </div>
  )
}
