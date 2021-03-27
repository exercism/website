import {
  ConceptPathProperties,
  ConceptPathCoordinate,
  ConceptPathStatus,
  ConceptStatus,
  PathCourse,
} from '../concept-map-types'
import {
  getCircleRadius,
  getLineWidth,
  getDrawingMargin,
} from './style-helpers'

export function computePathProperties(
  pathStartElement: HTMLElement,
  pathEndElement: HTMLElement
): ConceptPathProperties {
  const course = getPathCourse(pathStartElement, pathEndElement)
  const startCoordinate = getPathStartFromElement(pathStartElement, course)
  const endCoordinate = getPathEndFromElement(pathEndElement)
  const radius = getCircleRadius()
  const lineWidth = getLineWidth()
  const margin = getDrawingMargin()

  // calculate minimum dimensions for view-box
  const width =
    Math.abs(endCoordinate.x - startCoordinate.x) +
    2 * radius +
    2 * lineWidth +
    margin * 2
  const height =
    Math.abs(endCoordinate.y - startCoordinate.y) +
    2 * radius +
    2 * lineWidth +
    margin * 2

  const isLeftToRight = startCoordinate.x <= endCoordinate.x

  return {
    width,
    height,
    radius,
    pathCourse: course,
    pathStart: {
      x: isLeftToRight
        ? radius + lineWidth + margin
        : width - radius - lineWidth - margin,
      y: radius + lineWidth + margin,
    },
    pathEnd: {
      x: isLeftToRight
        ? width - radius - lineWidth - margin
        : radius + lineWidth + margin,
      y: height - radius - lineWidth - margin,
    },
    status: getPathStatus(pathEndElement),
    translateX:
      (isLeftToRight ? startCoordinate.x : endCoordinate.x) -
      radius -
      lineWidth -
      margin,
    translateY: startCoordinate.y - radius - lineWidth - margin,
  }
}

// calculate the start position of the path
function getPathStartFromElement(
  el: HTMLElement,
  course: PathCourse
): ConceptPathCoordinate {
  switch (course) {
    case 'left':
    case 'center-left':
      return getPathPointFromLeft(el)
    case 'right':
    case 'center-right':
      return getPathPointFromRight(el)
    case 'center':
    default:
      return getPathPointFromBottom(el)
  }
}

// calculate the end position of the path
function getPathEndFromElement(el: HTMLElement): ConceptPathCoordinate {
  return getPathPointFromTop(el)
}

function getPathPointFromTop(el: HTMLElement): ConceptPathCoordinate {
  const x = Math.floor(el.offsetLeft + el.offsetWidth / 2)
  const y = Math.floor(el.offsetTop)

  return { x, y }
}

function getPathPointFromBottom(el: HTMLElement): ConceptPathCoordinate {
  const x = Math.floor(el.offsetLeft + el.offsetWidth / 2)
  const y = Math.ceil(el.offsetTop + el.offsetHeight)

  return { x, y }
}

function getPathPointFromLeft(el: HTMLElement): ConceptPathCoordinate {
  const x = Math.floor(el.offsetLeft)
  const y = Math.floor(el.offsetTop + el.offsetHeight / 2)

  return { x, y }
}

function getPathPointFromRight(el: HTMLElement): ConceptPathCoordinate {
  const x = Math.floor(el.offsetLeft + el.offsetWidth)
  const y = Math.floor(el.offsetTop + el.offsetHeight / 2)

  return { x, y }
}

// Derive the path state from the concept state
function getPathStatus(el: HTMLElement): ConceptPathStatus {
  const conceptStatus = el.dataset.conceptStatus as ConceptStatus

  switch (conceptStatus) {
    case 'available':
    case 'learned':
    case 'mastered':
      return 'unlocked'
    default:
      return 'locked'
  }
}

function getPathCourse(
  parentEl: HTMLElement,
  childEl: HTMLElement
): PathCourse {
  const childOffsetRight = childEl.offsetLeft + childEl.offsetWidth
  const childOffsetLeft = childEl.offsetLeft
  const childOffsetCenter = childEl.offsetLeft + childEl.offsetWidth / 2

  const parentOffsetRight = parentEl.offsetLeft + parentEl.offsetWidth
  const parentOffsetLeft = parentEl.offsetLeft

  const margin = 20

  if (childOffsetRight <= parentOffsetLeft) {
    return 'left'
  }

  if (childOffsetCenter + margin <= parentOffsetLeft) {
    return 'center-left'
  }

  if (childOffsetLeft >= parentOffsetRight) {
    return 'right'
  }

  if (childOffsetCenter - margin >= parentOffsetRight) {
    return 'center-right'
  }

  return 'center'
}
