import React from 'react'

import { ConceptPathCoordinate } from './concept-map-types'

export const PathLineSVG = ({
  pathStart,
  pathEnd,
}: {
  pathStart: ConceptPathCoordinate
  pathEnd: ConceptPathCoordinate
}): JSX.Element => {
  const computedBezier = React.useMemo(() => {
    const halfDeltaY = (pathEnd.y - pathStart.y) / 2
    const dx1 = pathStart.x
    const dy1 = pathStart.y + halfDeltaY
    const dx2 = pathEnd.x
    const dy2 = pathEnd.y - halfDeltaY

    return `M ${pathStart.x}, ${pathStart.y} C ${dx1}, ${dy1} ${dx2}, ${dy2} ${pathEnd.x}, ${pathEnd.y}`
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [pathStart.x, pathStart.y, pathEnd.x, pathEnd.y])

  return <path d={computedBezier} />
}

export const PurePathLineSVG = React.memo(PathLineSVG)
