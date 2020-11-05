import React, { useEffect } from 'react'

export default function MonacoEditor({
  value,
  editorDidMount,
  theme,
  options,
  language,
  onChange,
}) {
  const editor = {
    getValue: () => {
      return value
    },
  }

  const handleChange = (e) => {
    onChange(e.target.value, e)
  }

  useEffect(() => {
    editorDidMount(editor, null)
  }, [])

  return (
    <div>
      <p>Theme: {theme}</p>
      <p>Language: {language}</p>
      <p>Wrap: {options.wordWrap}</p>
      <p>Value: {value}</p>
      <textarea
        data-testid="editor-value"
        onChange={handleChange}
        value={value}
      ></textarea>
    </div>
  )
}
