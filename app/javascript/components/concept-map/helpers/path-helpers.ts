import {
  ConceptPath,
  ConceptPathCoordinate,
  ConceptPathStatus,
  ConceptStatus,
} from '../concept-map-types'

export function determinePath(
  pathStartElement: HTMLElement,
  pathEndElement: HTMLElement
): ConceptPath {
  const conceptStatus = pathEndElement.dataset.conceptStatus as ConceptStatus

  return {
    start: getPathStartFromElement(pathStartElement),
    end: getPathEndFromElement(pathEndElement),
    status: getPathState(conceptStatus),
  }
}

export function normalizePathToCanvasSize(
  path: ConceptPath,
  width: number,
  height: number
): ConceptPath {
  // Use :root defined CSS variable values to style the path
  const rootStyle = getComputedStyle(document.documentElement)
  const radius = Number(
    rootStyle.getPropertyValue('--c-concept-map-circle-radius')
  )
  const lineWidth = Number(
    rootStyle.getPropertyValue('--c-concept-map-line-width')
  )

  const leftToRight = path.start.x <= path.end.x

  return {
    start: {
      x: leftToRight ? radius + lineWidth : width - radius - lineWidth,
      y: radius + lineWidth,
    },
    end: {
      x: leftToRight ? width - radius - lineWidth : radius + lineWidth,
      y: height - radius - lineWidth,
    },
    status: path.status,
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
function getPathState(conceptStatus: ConceptStatus): ConceptPathStatus {
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
