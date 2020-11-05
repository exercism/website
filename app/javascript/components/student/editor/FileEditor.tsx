import React, {
  forwardRef,
  useImperativeHandle,
  useRef,
  useCallback,
  useState,
} from 'react'
import { File } from '../Editor'
import MonacoEditor from 'react-monaco-editor'
import * as monacoEditor from 'monaco-editor/esm/vs/editor/editor.api'

export type FileEditorHandle = {
  getFile: () => File
}

type FileEditorProps = {
  file: File
  syntaxHighlighter: string
}

export const FileEditor = forwardRef<FileEditorHandle, FileEditorProps>(
  ({ file, syntaxHighlighter }, ref) => {
    const [options, setOptions] = useState({
      minimap: { enabled: false },
      wordWrap: 'on',
    })
    const editorRef = useRef<monacoEditor.editor.IStandaloneCodeEditor>()
    const editorDidMount = useCallback(
      (editor) => {
        editorRef.current = editor
      },
      [editorRef]
    )
    const handleWrapChange = useCallback((e) => {
      setOptions({ ...options, wordWrap: e.target.value })
    })

    useImperativeHandle(ref, () => ({
      getFile() {
        return {
          filename: file.filename,
          content: editorRef.current?.getValue() || '',
        }
      },
    }))

    return (
      <div>
        <label>Wrap</label>
        <select value={options.wordWrap} onChange={handleWrapChange}>
          <option value="off">Off</option>
          <option value="on">On</option>
        </select>
        <MonacoEditor
          key={file.filename}
          width="800"
          height="600"
          language={syntaxHighlighter}
          editorDidMount={editorDidMount}
          options={options}
          defaultValue={file.content}
        />
      </div>
    )
  }
)
