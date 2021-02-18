import React from 'react'
import { Icon } from '../../common/Icon'
import pluralize from 'pluralize'

export const PreviousSessionsLink = ({
  numSessions,
}: {
  numSessions: number
}): JSX.Element | null => {
  if (numSessions === 0) {
    return null
  }

  return (
    <div className="previous-sessions">
      See {numSessions} previous {pluralize('session', numSessions)}
      <Icon icon="modal" alt="Opens in modal" />
    </div>
  )
}
