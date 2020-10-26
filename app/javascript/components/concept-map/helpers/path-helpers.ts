import {
  ConceptPathProperties,
  ConceptPathCoordinate,
  ConceptPathStatus,
  ConceptStatus,
} from '../concept-map-types'
import { getCircleRadius, getLineWidth } from './style-helpers'

export function computePathProperties(
  pathStartElement: HTMLElement,
  pathEndElement: HTMLElement
): ConceptPathProperties {
  const startCoordinate = getPathStartFromElement(pathStartElement)
  const endCoordinate = getPathEndFromElement(pathEndElement)
  const radius = getCircleRadius()
  const lineWidth = getLineWidth()

  // calculate minimum dimensions for view-box
  const width =
    Math.abs(endCoordinate.x - startCoordinate.x) + 2 * radius + 2 * lineWidth
  const height =
    Math.abs(endCoordinate.y - startCoordinate.y) + 2 * radius + 2 * lineWidth

  const isLeftToRight = startCoordinate.x <= endCoordinate.x

  return {
    width,
    height,
    radius,
    pathStart: {
      x: isLeftToRight ? radius + lineWidth : width - radius - lineWidth,
      y: radius + lineWidth,
    },
    pathEnd: {
      x: isLeftToRight ? width - radius - lineWidth : radius + lineWidth,
      y: height - radius - lineWidth,
    },
    status: getPathStatus(pathEndElement),
    translateX:
      (isLeftToRight ? startCoordinate.x : endCoordinate.x) -
      radius -
      lineWidth,
    translateY: startCoordinate.y - radius - lineWidth,
  }
}

// calculate the start position of the path
function getPathStartFromElement(el: HTMLElement): ConceptPathCoordinate {
  const x = Math.floor(el.offsetLeft + el.offsetWidth / 2) + 0.5
  const y = Math.ceil(el.offsetTop + el.offsetHeight)

  return { x, y }
}

// calculate the end position of the path
function getPathEndFromElement(el: HTMLElement): ConceptPathCoordinate {
  const x = Math.floor(el.offsetLeft + el.offsetWidth / 2) + 0.5
  const y = Math.floor(el.offsetTop)

  return { x, y }
}

// Derive the path state from the concept state
function getPathStatus(el: HTMLElement): ConceptPathStatus {
  const conceptStatus = el.dataset.conceptStatus as ConceptStatus

  switch (conceptStatus) {
    case 'unlocked':
    case 'in_progress':
      return 'available'
    case 'completed':
      return 'complete'
    default:
      return 'locked'
  }
}
