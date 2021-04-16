import React from 'react'
import { GraphicalIcon } from '../../common'

export const TotalReputation = ({
  handle,
  reputation,
}: {
  handle: string
  reputation: number
}): JSX.Element => {
  return (
    <div className="c-primary-reputation --large">
      <div className="--inner">
        {handle} has
        <GraphicalIcon icon="reputation" />
        {reputation} Reputation
      </div>
    </div>
  )
}
