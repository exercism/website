import React, { useState, useEffect, useCallback } from 'react'

import { File } from '@/components/types'
import { EditorSettings } from '../types'

export enum Keybindings {
  DEFAULT = 'default',
  VIM = 'vim',
  EMACS = 'emacs',
}

export type FileEditorHandle = {
  getFiles: () => File[]
  setFiles: (files: File[]) => void
  focus: () => void
}

export function FileEditorCodeMirror({
  editorDidMount,
  language,
  files: defaultFiles,
  settings,
  readonly,
}: {
  editorDidMount: (editor: FileEditorHandle) => void
  language: string
  settings: EditorSettings
  files: File[]
  readonly: boolean
}): JSX.Element {
  const [files, setFiles] = useState<File[]>(defaultFiles)
  const getFiles = useCallback(() => {
    return files
  }, [files])

  useEffect(() => {
    editorDidMount({
      getFiles,
      setFiles,
      focus: () => null,
    })
  }, [editorDidMount, getFiles, files, setFiles])

  return (
    <div>
      <p>Theme: {settings.theme}</p>
      <p>Language: {language}</p>
      <p>Keybindings: {settings.keybindings}</p>
      <p>Wrap: {settings.wrap}</p>
      <p>Tab behavior: {settings.tabBehavior}</p>
      <p>Readonly: {readonly.toString()}</p>
      {files.map((file) => (
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
