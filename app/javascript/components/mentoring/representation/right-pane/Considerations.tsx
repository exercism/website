import { Icon } from '@/components/common'
import React from 'react'
import { CompleteRepresentationData } from '../../../types'

export default function Considerations({
  guidance,
}: Pick<CompleteRepresentationData, 'guidance'>): JSX.Element | null {
  return (
    <p className="px-24 mt-16 text-p-base text-warning flex items-center">
      <Icon
        className="h-[16px] w-[16px] filter-orange mr-8"
        icon="warning"
        alt="Please read this"
      />
      Please read&nbsp;
      <a
        href={guidance.links.representationFeedbackGuide}
        target="_blank"
        rel="noreferrer"
        className="!text-warning underline"
      >
        this
      </a>
      &nbsp; before giving your first feedback.
    </p>
  )
}
