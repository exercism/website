import React from 'react'
import { GraphicalIcon } from './GraphicalIcon'

export const ProminentLink = ({
  link,
  text,
}: {
  link: string
  text: string
}): JSX.Element => {
  return (
    <a href={link} className="c-prominent-link">
      <span>{text}</span>
      <GraphicalIcon icon="arrow-right" />
    </a>
  )
}
