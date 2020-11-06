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
import { useStorage } from '../../../utils/use-storage'

export type FileEditorHandle = {
  getFile: () => File
}

type FileEditorProps = {
  file: File
  language: string
  onRunTests: () => void
}

export const FileEditor = forwardRef<FileEditorHandle, FileEditorProps>(
  ({ file, language, onRunTests }, ref) => {
    const [theme, setTheme] = useState('vs')
    const [options, setOptions] = useState({
      minimap: { enabled: false },
      wordWrap: 'on',
    })
    const [content, setContent] = useStorage(
      `${file.filename}-editor-content`,
      file.content
    )
    const editorRef = useRef<monacoEditor.editor.IStandaloneCodeEditor>()
    const editorDidMount = useCallback(
      (editor) => {
        editor.addAction({
          id: 'runTests',
          label: 'Run tests',
          keybindings: [monacoEditor.KeyCode.F2],
          run: onRunTests,
        })
        editorRef.current = editor
      },
      [editorRef]
    )
    const editorChanged = useCallback(
      (newValue, e) => {
        setContent(newValue)
      },
      [setContent]
    )
    const handleWrapChange = useCallback(
      (e) => {
        setOptions({ ...options, wordWrap: e.target.value })
      },
      [setOptions]
    )
    const handleThemeChange = useCallback(
      (e) => {
        setTheme(e.target.value)
      },
      [setTheme]
    )
    const revertContent = useCallback(
      (e) => {
        setContent(file.content)
      },
      [setContent, file]
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
      <div>
        <label htmlFor={`${file.filename}-editor-wrap`}>Wrap</label>
        <select
          id={`${file.filename}-editor-wrap`}
          value={options.wordWrap}
          onChange={handleWrapChange}
        >
          <option value="off">Off</option>
          <option value="on">On</option>
        </select>
        <label>Theme</label>
        <label htmlFor={`${file.filename}-editor-theme`}>Theme</label>
        <select
          id={`${file.filename}-editor-theme`}
          value={theme}
          onChange={handleThemeChange}
        >
          <option value="vs">Light</option>
          <option value="vs-dark">Dark</option>
        </select>
        {content !== file.content && (
          <button onClick={revertContent} type="button">
            Revert to last run code
          </button>
        )}
        <MonacoEditor
          key={file.filename}
          width="800"
          height="600"
          language={language}
          editorDidMount={editorDidMount}
          onChange={editorChanged}
          options={options}
          value={content}
          theme={theme}
        />
      </div>
    )
  }
)
