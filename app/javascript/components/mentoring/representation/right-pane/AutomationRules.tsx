import React from 'react'
import { CompleteRepresentationData } from '../../../types'
import AlertText from './AlertText'

export default function AutomationRules({
  guidance,
}: Pick<CompleteRepresentationData, 'guidance'>): JSX.Element {
  return (
    <div className="px-24 shadow-xsZ1v2 mb-24">
      <AlertText text="Important rules when giving feedback" />
      <div
        dangerouslySetInnerHTML={{
          __html: `<div class="c-textual-content --base">${guidance.representationsHtml}</div>`,
        }}
      />
    </div>
  )
}
