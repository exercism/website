import React from 'react'
import { GraphicalIcon } from '../..'

export const Outdated = (): JSX.Element => {
  return (
    <div className="--out-of-date">
      <GraphicalIcon icon="warning" />
      <div className="--status">Outdated</div>
    </div>
  )
}
