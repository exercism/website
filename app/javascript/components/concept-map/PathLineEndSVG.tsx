import React from 'react'
import { ConceptPathCoordinate, ConceptPathStatus } from './concept-map-types'

export const PathLineEndSVG = ({
  coordinate,
  radius,
  status,
}: {
  coordinate: ConceptPathCoordinate
  radius: number
  status: ConceptPathStatus
}): JSX.Element => {
  return (
    <circle
      cx={coordinate.x}
      cy={coordinate.y}
      r={radius}
      className={`line-width-2 end-cap ${status}`}
    />
  )
}
