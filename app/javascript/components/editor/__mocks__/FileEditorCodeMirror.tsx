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
  files,
  settings,
}: {
  editorDidMount: (editor: FileEditorHandle) => void
  language: string
  settings: EditorSettings
  files: File[]
}): JSX.Element {
  const [isPaletteOpen, setIsPaletteOpen] = useState(false)
  const textareaRef = useRef(files.map(() => createRef<HTMLTextAreaElement>()))
  const getFiles = useCallback(() => {
    return textareaRef.current.map((ref, i) => {
      if (!ref.current) {
        throw 'No files found'
      }

      return {
        filename: files[i].filename,
        content: ref.current.value,
      }
    })
  }, [files])

  const setFiles = useCallback((files) => {
    return textareaRef.current.map((ref, i) => {
      if (!ref.current) {
        return
      }

      ref.current.value = files[i].content
    })
  }, [])

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
            ref={textareaRef.current[i]}
            defaultValue={file.content}
            data-testid="editor-value"
          />
        </div>
      ))}
    </div>
  )
}
