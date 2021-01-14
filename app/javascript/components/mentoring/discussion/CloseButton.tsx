import React from 'react'
import { GraphicalIcon } from '../../common'

export const CloseButton = ({ url }: { url: string }): JSX.Element => (
  <a href={url} className="close-btn" aria-label="Close discussion">
    <GraphicalIcon icon="arrow-left" />
  </a>
)
