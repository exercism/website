import React from 'react'
export function CodeRun({ codeRun }: { codeRun: string }) {
  if (!codeRun || codeRun.length === 0) return null
  return (
    <>
      <h5>Code run:</h5>
      <p>{codeRun}</p>
    </>
  )
}
