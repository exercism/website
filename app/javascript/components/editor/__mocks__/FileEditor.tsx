import React, { createRef, useRef, useEffect, useCallback } from 'react'
import { useSaveFiles } from '../file-editor/useSaveFiles'

export enum Keybindings {
  DEFAULT = 'default',
  VIM = 'vim',
  EMACS = 'emacs',
}

export function FileEditor({
  files: initialFiles,
  language,
  editorDidMount,
  wrap,
  theme,
  keybindings,
}): JSX.Element {
  const textareaRef = useRef(initialFiles.map(() => createRef()))
  const [files] = useSaveFiles(initialFiles, () => {
    return getFiles()
  })

  const getFiles = useCallback(() => {
    return textareaRef.current.map((ref, i) => {
      return { filename: files[i].filename, content: ref.current.value }
    })
  }, [files])

  const setFiles = useCallback(() => {
    return textareaRef.current.map((ref, i) => {
      ref.current.value = initialFiles[i].content
    })
  }, [initialFiles])

  useEffect(() => {
    editorDidMount({ getFiles, setFiles })
  }, [editorDidMount, getFiles, initialFiles, setFiles])

  return (
    <div>
      <p>Theme: {theme}</p>
      <p>Language: {language}</p>
      <p>Keybindings: {keybindings}</p>
      <p>Wrap: {wrap}</p>
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
