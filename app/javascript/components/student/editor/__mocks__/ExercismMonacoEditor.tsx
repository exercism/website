import React, { useEffect, useRef } from 'react'

export enum Keybindings {
  DEFAULT = 'default',
  VIM = 'vim',
}

export function ExercismMonacoEditor({
  width,
  height,
  language,
  editorDidMount,
  onRunTests,
  options,
  value,
  theme,
  keybindings,
}) {
  const textareaRef = useRef<HTMLTextArea | undefined>()
  const editor = {
    getValue: () => {
      return textareaRef.current?.value
    },
    setValue: (value) => {
      if (textareaRef.current) {
        textareaRef.current.value = value
      }
    },
  }

  useEffect(() => {
    editorDidMount(editor, null)
  }, [])

  return (
    <div>
      <p>Theme: {theme}</p>
      <p>Language: {language}</p>
      <p>Keybindings: {keybindings}</p>
      <p>Wrap: {options.wordWrap}</p>
      <p>Value: {value}</p>
      <textarea
        ref={textareaRef}
        data-testid="editor-value"
        defaultValue={value}
      ></textarea>
    </div>
  )
}
