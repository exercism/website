import React from 'react'
import { CompleteRepresentationData } from '../../../types'

export default function AutomationRules({
  information,
}: Pick<CompleteRepresentationData, 'information'>): JSX.Element | null {
  if (!information.representationsHtml) {
    return null
  }

  return (
    <div className="px-24 shadow-xsZ1v2 mb-24">
      <h2 className="text-h4 mb-12">Please read before giving feedback</h2>
      <div
        dangerouslySetInnerHTML={{
          __html: `<div class="c-textual-content --base">${information.representationsHtml}</div>`,
        }}
      />
    </div>
  )
}
