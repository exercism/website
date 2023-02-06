import React from 'react'
import { CompleteRepresentationData } from '../../../types'

export default function AutomationRules({
  guidance,
}: Pick<CompleteRepresentationData, 'guidance'>): JSX.Element | null {
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
      <p className="px-24 mb-16 text-p-base">
        This representer doesn&apos;t have any guidance yet. Guidance notes are
        written by our maintainers to explain what normalizations occur during
        the representation process. If you are a maintainer, please help get
        them started for this representer by sending a {prLink}.
      </p>
    )
  }

  return (
    <div className="px-24 shadow-xsZ1v2 pt-12 pb-24">
      <h2 className="text-h4 mb-12">Please read before giving feedback</h2>
      <div
        dangerouslySetInnerHTML={{
          __html: `<div class="c-textual-content --base">${guidance.representations}</div>`,
        }}
      />
    </div>
  )
}
