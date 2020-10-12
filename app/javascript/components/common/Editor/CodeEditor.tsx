import React, { useState } from 'react'

export function CodeEditor({ onSubmit }: { onSubmit: (code: string) => void }) {
  const [code, setCode] = useState('')

  function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()

    onSubmit(code)
  }

  function handleChange(e: React.ChangeEvent<HTMLTextAreaElement>) {
    setCode(e.target.value)
  }

  return (
    <form onSubmit={handleSubmit}>
      <label htmlFor="code">Code</label>
      <textarea onChange={handleChange} id="code"></textarea>
      <button>Submit</button>
    </form>
  )
}
