import React from 'react'

export const PreviousSessionsLink = ({
  numSessions,
}: {
  numSessions: number
}): JSX.Element | null => {
  if (numSessions === 0) {
    return null
  }

  return <div>{numSessions} previous sessions</div>
}
