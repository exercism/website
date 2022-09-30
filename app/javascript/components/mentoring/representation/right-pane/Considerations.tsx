import React from 'react'
import { CompleteRepresentationData } from '../../../types'

export default function Considerations({
  guidance,
}: Pick<CompleteRepresentationData, 'guidance'>): JSX.Element | null {
  return (
    <p className="px-24 py-16 text-p-base warning">
      Please read{' '}
      <a
        href={guidance.links.representationFeedbackGuide}
        target="_blank"
        rel="noreferrer"
      >
        this
      </a>{' '}
      before giving your first feedback.
    </p>
  )
}
