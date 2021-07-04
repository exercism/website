import React from 'react'
import { Icon } from '../../../../common'

export const TrackProgressBar = ({
  completion,
}: {
  completion: number
}): JSX.Element => {
  const isComplete = completion === 100
  const classNames = [
    'c-progress',
    '--small',
    isComplete ? '--completed' : '',
  ].filter((className) => className.length > 0)

  return (
    <div className={classNames.join(' ')}>
      <div className="bar" style={{ width: `${completion}%` }} />
      {isComplete ? (
        <div className="completed-icon">
          <Icon
            icon="completed-check-circle"
            alt="Completed"
            className="completed"
          />
        </div>
      ) : null}
    </div>
  )
}
