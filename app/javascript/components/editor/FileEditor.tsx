import React, {
  forwardRef,
  useRef,
  useImperativeHandle,
  useCallback,
} from 'react'
import { File, Keybindings, WrapSetting } from './types'
import { ExercismMonacoEditor } from './ExercismMonacoEditor'
import * as monacoEditor from 'monaco-editor/esm/vs/editor/editor.api'
import { useLocalStorage } from '../../utils/use-storage'

export type FileEditorHandle = {
  getFile: () => File
}

type FileEditorProps = {
  file: File
  language: string
  onRunTests: () => void
  onSubmit: () => void
  theme: string
  keybindings: Keybindings
  wrap: WrapSetting
}

export const FileEditor = forwardRef<FileEditorHandle, FileEditorProps>(
  ({ file, language, onRunTests, onSubmit, theme, keybindings, wrap }, ref) => {
    const options: monacoEditor.editor.IStandaloneEditorConstructionOptions = {
      minimap: { enabled: false },
      wordWrap: wrap,
      glyphMargin: true,
      lightbulb: { enabled: true },
      automaticLayout: true,
    }
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
      <div className="c-file-editor">
        <ExercismMonacoEditor
          key={file.filename}
          language={language}
          editorDidMount={editorDidMount}
          onRunTests={onRunTests}
          onSubmit={onSubmit}
          options={options}
          defaultValue={file.content}
          theme={theme}
          keybindings={keybindings}
        />
      </div>
    )
  }
)
