import React from 'react'
import { GraphicalIcon } from '../../common'

export const TotalReputation = ({
  handle,
  reputation,
}: {
  handle?: string
  reputation: number
}): JSX.Element => {
  const address = handle ? `${handle} has` : 'You have'

  return (
    <div className="c-primary-reputation --large">
      {address}
      <GraphicalIcon icon="reputation" />
      {reputation.toLocaleString()} Reputation
    </div>
  )
}
