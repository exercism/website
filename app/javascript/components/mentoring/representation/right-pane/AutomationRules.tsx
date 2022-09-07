import React from 'react'
import { CompleteRepresentationData } from '../../../types'

export default function AutomationRules({
  guidance,
}: Pick<CompleteRepresentationData, 'guidance'>): JSX.Element | null {
  console.log(guidance)

  const prLink = (
    <a
      href={guidance.links.improveRepresenterGuidance}
      target="_blank"
      rel="noreferrer"
    >
      Pull Request on GitHub
    </a>
  )

  if (!guidance.representations) {
    return (
      <p className="px-24 py-16 text-p-base">
        This representer doesn&apos;t have any guidance yet. Guidance notes are
        written by our community. Please help get them started for this exercise
        by sending a {prLink}.
      </p>
    )
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
