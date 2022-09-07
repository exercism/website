import React from 'react'
import { CompleteRepresentationData } from '../../../types'

export default function AutomationRules({
  guidance,
}: Pick<CompleteRepresentationData, 'guidance'>): JSX.Element | null {
  if (!guidance.representations) {
    return null
  }

  return (
    <div className="px-24 shadow-xsZ1v2 mb-24">
      <h2 className="text-h4 mb-12">Please read before giving feedback</h2>
      <div
        dangerouslySetInnerHTML={{
          __html: `<div class="c-textual-content --base">${guidance.representations}</div>`,
        }}
      />
    </div>
  )
}
