import React from 'react'
import { ConceptPathStatus } from './concept-map-types'

export const PathLineEndSVG = ({
  cx,
  cy,
  radius,
  status,
}: {
  cx: number
  cy: number
  radius: number
  status: ConceptPathStatus
}): JSX.Element => {
  return (
    <circle
      cx={cx}
      cy={cy}
      r={radius}
      className={`line-width-2 end-cap ${status}`}
    />
  )
}

export const PurePathLineEndSVG = React.memo(PathLineEndSVG)
