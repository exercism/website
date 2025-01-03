import React from 'react'
export function StateTestResultView({ errorHtml }: { errorHtml: string }) {
  return (
    <div
      className="text-bootcamp-fail-dark font-medium content"
      dangerouslySetInnerHTML={{ __html: errorHtml }}
    />
  )
}
