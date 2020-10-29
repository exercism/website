import React, { useEffect } from 'react'

export default function MonacoEditor({ defaultValue, editorDidMount }) {
  const editor = {
    getValue: () => {
      return defaultValue
    },
  }

  useEffect(() => {
    editorDidMount(editor, null)
  }, [])

  return <p>{defaultValue}</p>
}
