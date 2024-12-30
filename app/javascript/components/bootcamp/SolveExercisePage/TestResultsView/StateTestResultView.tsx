import React from 'react'
export function StateTestResultView({
  descriptionHtml,
}: {
  descriptionHtml: string
}) {
  return (
    <div
      className="border border-slate-600 rounded-md p-4 mb-4"
      dangerouslySetInnerHTML={{ __html: descriptionHtml }}
    />
  )
}
