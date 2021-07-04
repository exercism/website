import React from 'react'

import { PathCourse, ConceptPathCoordinate } from './concept-map-types'

export const PathLineSVG = ({
  pathStart,
  pathEnd,
  course,
}: {
  pathStart: ConceptPathCoordinate
  pathEnd: ConceptPathCoordinate
  course: PathCourse
}): JSX.Element => {
  const computedBezier: string = React.useMemo(
    () => computeCurve(pathStart, pathEnd, course),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [pathStart.x, pathStart.y, pathEnd.x, pathEnd.y, course]
  )

  return <path d={computedBezier} />
}

export const PurePathLineSVG = React.memo(PathLineSVG)

function computeCurve(
  start: ConceptPathCoordinate,
  end: ConceptPathCoordinate,
  course: PathCourse
): string {
  switch (course) {
    case 'left':
      return drawLeft(start, end)
    case 'right':
      return drawRight(start, end)
    case 'center-left':
      return drawCenterLeft(start, end)
    case 'center-right':
      return drawCenterRight(start, end)
  }
  return drawTopDown(start, end)
}

function drawTopDown(start: ConceptPathCoordinate, end: ConceptPathCoordinate) {
  const halfDeltaY = (end.y - start.y) / 2
  const dx1 = start.x
  const dy1 = start.y + halfDeltaY
  const dx2 = end.x
  const dy2 = end.y - halfDeltaY

  return `M ${start.x}, ${start.y} C ${dx1}, ${dy1} ${dx2}, ${dy2} ${end.x}, ${end.y}`
}

function drawLeft(start: ConceptPathCoordinate, end: ConceptPathCoordinate) {
  const deltaX = start.x - end.x
  const deltaY = end.y - start.y
  const dx1 = start.x - deltaX * 0.5
  const dy1 = start.y
  const dx2 = end.x
  const dy2 = end.y - deltaY * 0.5

  return `M ${start.x}, ${start.y} C ${dx1}, ${dy1} ${dx2}, ${dy2} ${end.x}, ${end.y}`
}

function drawRight(start: ConceptPathCoordinate, end: ConceptPathCoordinate) {
  const deltaX = end.x - start.x
  const deltaY = end.y - start.y
  const dx1 = start.x + deltaX * 0.5
  const dy1 = start.y
  const dx2 = end.x
  const dy2 = end.y - deltaY * 0.5

  return `M ${start.x}, ${start.y} C ${dx1}, ${dy1} ${dx2}, ${dy2} ${end.x}, ${end.y}`
}

function drawCenterRight(
  start: ConceptPathCoordinate,
  end: ConceptPathCoordinate
) {
  const deltaX = Math.abs(start.x - end.x)
  const halfDeltaY = (end.y - start.y) / 2
  const dx1 = start.x + deltaX * 0.5
  const dy1 = start.y
  const dx2 = end.x
  const dy2 = end.y - halfDeltaY

  return `M ${start.x}, ${start.y} C ${dx1}, ${dy1} ${dx2}, ${dy2} ${end.x}, ${end.y}`
}

function drawCenterLeft(
  start: ConceptPathCoordinate,
  end: ConceptPathCoordinate
) {
  const deltaX = Math.abs(start.x - end.x)
  const halfDeltaY = (end.y - start.y) / 2
  const dx1 = start.x - deltaX * 0.5
  const dy1 = start.y
  const dx2 = end.x
  const dy2 = end.y - halfDeltaY

  return `M ${start.x}, ${start.y} C ${dx1}, ${dy1} ${dx2}, ${dy2} ${end.x}, ${end.y}`
}
