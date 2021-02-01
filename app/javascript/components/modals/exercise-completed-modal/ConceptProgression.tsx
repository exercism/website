import React from 'react'
import { Icon } from '../../common'
import { ConceptIcon } from '../../common/ConceptIcon'

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
  from,
  to,
  total,
}: {
  name: string
  from: number
  to: number
  total: number
}): JSX.Element => {
  const isMastered = to === total

  return (
    <div className="concept">
      <ConceptIcon name={name} size="medium" />
      <div className="name">{name}</div>
      <ProgressBar isMastered={isMastered} from={from} to={to} total={total} />
      {isMastered ? (
        <Icon
          icon="completed-check-circle"
          alt="Concept completed"
          className="completed"
        />
      ) : (
        <div className="completed" />
      )}
    </div>
  )
}
