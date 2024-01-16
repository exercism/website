import React from 'react'
import { Icon } from '../../../common'
import { ConceptIcon } from '../../../common/ConceptIcon'

const ProgressBar = ({
  isMastered,
  from,
  to,
  total,
}: {
  isMastered: boolean
  from: number
  to: number
  total: number
}) => {
  const classNames = ['c-concept-progress-bar']

  if (isMastered) {
    classNames.push('--completed')
  }

  return <progress className={classNames.join(' ')} value={to} max={total} />
}

export const ConceptProgression = ({
  name,
  links,
}: {
  name: string
  links: { self: string }
}): JSX.Element => {
  return (
    <a href={links.self} className="concept">
      <ConceptIcon name={name} size="medium" />
      <div className="name">{name}</div>
      <div className="exercises">
        <div className="c-ed --completed --concept" />
      </div>
    </a>
  )
}
