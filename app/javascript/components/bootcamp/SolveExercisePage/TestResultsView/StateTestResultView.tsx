import React from 'react'
export function StateTestResultView({
  descriptionHtml,
}: {
  descriptionHtml: string
}) {
  return (
    <div
      className="text-bootcamp-fail-dark font-medium content"
      dangerouslySetInnerHTML={{ __html: descriptionHtml }}
    />
  )
}
