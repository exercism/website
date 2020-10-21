import React, { useRef } from 'react'
import { Action } from '../Editor'

export function CodeEditor({
  dispatch,
}: {
  dispatch: (action: Action) => void
}) {
  const editor = useRef<HTMLTextAreaElement>(null)

  function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()

    if (editor.current === null) {
      return
    }

    dispatch({ type: 'submitting', payload: { code: editor.current.value } })
  }

  return (
    <form onSubmit={handleSubmit}>
      <label htmlFor="student-code-editor-code">Code</label>
      <textarea ref={editor} id="student-code-editor-code"></textarea>
      <button>Submit</button>
    </form>
  )
}
