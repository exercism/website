import React from 'react'
import { GraphicalIcon } from '../../common'

export const OutOfDateNotice = (): JSX.Element => {
  return (
    <div className="--out-of-date">
      <GraphicalIcon icon="warning" />
      <div className="--status">Outdated</div>
    </div>
  )
}
