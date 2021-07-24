import React, {
  useState,
  createRef,
  useRef,
  useEffect,
  useCallback,
} from 'react'

import { EditorSettings } from '../../Editor'
import { File } from '../../types'

export enum Keybindings {
  DEFAULT = 'default',
  VIM = 'vim',
  EMACS = 'emacs',
}

export type FileEditorHandle = {
  getFiles: () => File[]
  setFiles: (files: File[]) => void
  openPalette: () => void
}

export function FileEditorCodeMirror({
  editorDidMount,
  language,
  files: defaultFiles,
  settings,
}: {
  editorDidMount: (editor: FileEditorHandle) => void
  language: string
  settings: EditorSettings
  files: File[]
}): JSX.Element {
  const [files, setFiles] = useState<File[]>(defaultFiles)
  const [isPaletteOpen, setIsPaletteOpen] = useState(false)
  const getFiles = useCallback(() => {
    return files
  }, [files])

  useEffect(() => {
    editorDidMount({
      getFiles,
      setFiles,
      openPalette: () => {
        setIsPaletteOpen(true)
      },
    })
  }, [editorDidMount, getFiles, files, setFiles])

  return (
    <div>
      <p>Theme: {settings.theme}</p>
      <p>Language: {language}</p>
      <p>Keybindings: {settings.keybindings}</p>
      <p>Wrap: {settings.wrap}</p>
      <p>Palette open: {isPaletteOpen.toString()}</p>
      <p>Tab behavior: {settings.tabBehavior}</p>
      {files.map((file, i) => (
        <div key={file.filename}>
          <p>Value: {file.content}</p>
          <textarea
            defaultValue={file.content}
            data-testid="editor-value"
            onChange={(e) => {
              setFiles(
                files.map((f) =>
                  file.filename === f.filename
                    ? { ...f, content: e.target.value }
                    : f
                )
              )
            }}
          />
        </div>
      ))}
    </div>
  )
}
