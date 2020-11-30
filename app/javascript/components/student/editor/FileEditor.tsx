import React, {
  forwardRef,
  useRef,
  useImperativeHandle,
  useCallback,
} from 'react'
import { File } from './types'
import { ExercismMonacoEditor, Keybindings } from './ExercismMonacoEditor'
import * as monacoEditor from 'monaco-editor/esm/vs/editor/editor.api'
import { useLocalStorage } from '../../../utils/use-storage'

export type FileEditorHandle = {
  getFile: () => File
}

type FileEditorProps = {
  file: File
  language: string
  onRunTests: () => void
  theme: string
}

export const FileEditor = forwardRef<FileEditorHandle, FileEditorProps>(
  ({ file, language, onRunTests, theme }, ref) => {
    const options: monacoEditor.editor.IStandaloneEditorConstructionOptions = {
      minimap: { enabled: false },
      wordWrap: 'on',
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
          options={options}
          value={file.content}
          theme={theme}
          keybindings={Keybindings.DEFAULT}
        />
      </div>
    )
  }
)
