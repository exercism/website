import React, { useEffect } from 'react'

export default function MonacoEditor({
  defaultValue,
  editorDidMount,
  theme,
  options,
  language,
}) {
  const editor = {
    getValue: () => {
      return defaultValue
    },
  }

  useEffect(() => {
    editorDidMount(editor, null)
  }, [])

  return (
    <div>
      <p>Theme: {theme}</p>
      <p>Language: {language}</p>
      <p>Wrap: {options.wordWrap}</p>
      <p>{defaultValue}</p>
    </div>
  )
}
