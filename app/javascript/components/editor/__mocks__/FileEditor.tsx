import React, {
  useState,
  createRef,
  useRef,
  useEffect,
  useCallback,
} from 'react'

export enum Keybindings {
  DEFAULT = 'default',
  VIM = 'vim',
  EMACS = 'emacs',
}

export function FileEditor({
  files,
  language,
  editorDidMount,
  wrap,
  theme,
  keybindings,
}): JSX.Element {
  const [isPaletteOpen, setIsPaletteOpen] = useState(false)
  const textareaRef = useRef(files.map(() => createRef()))
  const getFiles = useCallback(() => {
    return textareaRef.current.map((ref, i) => {
      return { filename: files[i].filename, content: ref.current.value }
    })
  }, [files])

  const setFiles = useCallback((files) => {
    return textareaRef.current.map((ref, i) => {
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
      <p>Theme: {theme}</p>
      <p>Language: {language}</p>
      <p>Keybindings: {keybindings}</p>
      <p>Wrap: {wrap}</p>
      <p>Palette open: {isPaletteOpen.toString()}</p>
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
