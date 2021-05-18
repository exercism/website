import React from 'react'
import { GraphicalIcon } from './GraphicalIcon'

export const ProminentLink = ({
  link,
  text,
  withBg,
  external,
}: {
  link: string
  text: string
  withBg?: boolean
  external?: boolean
}): JSX.Element => {
  const className = ['c-prominent-link', withBg ? '--with-bg' : ''].join(' ')

  /*TODO: Handle external - see app/helpers/view_components/prominent_link.rb*/
  return (
    <a href={link} className={className}>
      <span>{text}</span>
      <GraphicalIcon icon="arrow-right" />
    </a>
  )
}
