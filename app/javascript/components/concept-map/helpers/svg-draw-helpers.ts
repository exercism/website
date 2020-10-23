import { ConceptPath } from '../concept-map-types'

export const computeBezier = (path: ConceptPath): string => {
  const { start, end } = path
  const halfDeltaY = (end.y - start.y) / 2
  const dx1 = start.x
  const dy1 = start.y + halfDeltaY
  const dx2 = end.x
  const dy2 = end.y - halfDeltaY

  return `M ${start.x}, ${start.y} C ${dx1}, ${dy1} ${dx2}, ${dy2} ${end.x}, ${end.y}`
}
