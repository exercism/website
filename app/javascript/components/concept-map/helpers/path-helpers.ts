import {
  ConceptPath,
  ConceptPathCoordinate,
  ConceptPathState,
} from '../concept-connection-types'

import { ConceptStatus } from '../concept-types'

export function determinePath(
  pathStartElement: HTMLElement,
  pathEndElement: HTMLElement
): ConceptPath {
  const conceptStatus = pathEndElement.dataset.conceptStatus as ConceptStatus

  return {
    start: getPathStartFromElement(pathStartElement),
    end: getPathEndFromElement(pathEndElement),
    state: getPathState(conceptStatus),
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
    state: path.state,
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
function getPathState(conceptStatus: ConceptStatus): ConceptPathState {
  switch (conceptStatus) {
    case ConceptStatus.Unlocked:
    case ConceptStatus.InProgress:
      return ConceptPathState.Available
    case ConceptStatus.Completed:
      return ConceptPathState.Completed
    default:
      return ConceptPathState.Unavailable
  }
}
