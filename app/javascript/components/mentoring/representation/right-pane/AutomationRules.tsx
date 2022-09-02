import React from 'react'
import { CompleteRepresentationData } from '../../../types'
import AlertText from './AlertText'

export default function AutomationRules({
  rules,
}: Pick<CompleteRepresentationData, 'rules'>): JSX.Element {
  return (
    <div className="px-24 shadow-xsZ1v2 mb-24">
      <AlertText text="Important rules when giving feedback" />
      <div
        dangerouslySetInnerHTML={{
          __html: `<div class="c-textual-content --base">${rules.globalHtml}</div>`,
        }}
      />
      <div
        dangerouslySetInnerHTML={{
          __html: `<div class="c-textual-content --base">${rules.trackHtml}</div>`,
        }}
      />
      <div
        dangerouslySetInnerHTML={{
          __html: `<div class="c-textual-content --base">${rules.exerciseHtml}</div>`,
        }}
      />
    </div>
  )
}
