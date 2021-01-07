import React from 'react'
import { GraphicalIcon } from '../../common'

export const BackButton = ({ url }: { url: string }): JSX.Element => (
  <a href={url} className="close-btn" aria-label="Back to exercise">
    <GraphicalIcon icon="arrow-left" />
  </a>
)
