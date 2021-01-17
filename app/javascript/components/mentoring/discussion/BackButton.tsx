import React from 'react'
import { GraphicalIcon } from '../../common'

export const BackButton = ({ url }: { url: string }): JSX.Element => {
  return (
    <a
      href={url}
      className="close-btn"
      aria-label="Close discussion and return to mentoring dashboard"
    >
      <GraphicalIcon icon="close" />
    </a>
  )
}
