import React, { useEffect } from 'react'

export default function MonacoEditor({ value, editorDidMount }) {
  const editor = {
    getValue: () => {
      return value
    },
  }

  useEffect(() => {
    editorDidMount(editor, null)
  }, [])

  return <div />
}
