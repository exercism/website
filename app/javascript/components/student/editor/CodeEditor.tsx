import React, { useRef } from 'react'

export function CodeEditor({ onSubmit }: { onSubmit: (code: string) => void }) {
  const editor = useRef<HTMLTextAreaElement>(null)

  function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()

    if (editor.current === null) {
      return
    }

    onSubmit(editor.current.value)
  }

  return (
    <form onSubmit={handleSubmit}>
      <label htmlFor="student-code-editor-code">Code</label>
      <textarea ref={editor} id="student-code-editor-code"></textarea>
      <button>Submit</button>
    </form>
  )
}
