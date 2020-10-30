import React, {
  forwardRef,
  useImperativeHandle,
  useRef,
  useCallback,
} from 'react'
import { File } from '../Editor'
import MonacoEditor from 'react-monaco-editor'
import * as monacoEditor from 'monaco-editor/esm/vs/editor/editor.api'

export type FileEditorHandle = {
  getFile: () => File
}

type FileEditorProps = {
  file: File
}

export const FileEditor = forwardRef<FileEditorHandle, FileEditorProps>(
  ({ file }, ref) => {
    const editorRef = useRef<monacoEditor.editor.IStandaloneCodeEditor>()
    const editorDidMount = useCallback(
      (editor) => {
        editorRef.current = editor
      },
      [editorRef]
    )

    useImperativeHandle(ref, () => ({
      getFile() {
        return {
          filename: file.filename,
          content: editorRef.current?.getValue() || '',
        }
      },
    }))

    return (
      <MonacoEditor
        key={file.filename}
        width="800"
        height="600"
        language="ruby"
        editorDidMount={editorDidMount}
        defaultValue={file.content}
      />
    )
  }
)
