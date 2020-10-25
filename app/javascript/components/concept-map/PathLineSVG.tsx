import React from 'react'

import { ConceptPath } from './concept-map-types'

export const PathLineSVG = ({ path }: { path: ConceptPath }): JSX.Element => {
  const computedBezier = React.useMemo(() => {
    const { start, end } = path
    const halfDeltaY = (end.y - start.y) / 2
    const dx1 = start.x
    const dy1 = start.y + halfDeltaY
    const dx2 = end.x
    const dy2 = end.y - halfDeltaY

    return `M ${start.x}, ${start.y} C ${dx1}, ${dy1} ${dx2}, ${dy2} ${end.x}, ${end.y}`
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [path.start.x, path.start.y, path.end.x, path.end.y])

  return <path d={computedBezier} className={`line-width-2 ${path.status}`} />
}

export const PurePathLineSVG = React.memo(PathLineSVG)
