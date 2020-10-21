import {
  ConceptPath,
  ConceptConnection,
  ConceptPathCoordinate,
  ConceptPathState,
  isConceptPath,
} from '../concept-connection-types'

import { ConceptState } from '../concept-types'

import { conceptSlugToId } from '../Concept'

type CategorizedConceptPaths = {
  unavailable: ConceptPath[]
  available: ConceptPath[]
  completed: ConceptPath[]
}

export function mapToPaths(connections: ConceptConnection[]): ConceptPath[] {
  return connections
    .map(({ from, to }) => {
      const pathEndElement = document.getElementById(conceptSlugToId(to))
      const pathStartElement = document.getElementById(conceptSlugToId(from))

      // If the start or end concept doesn't exist for some reason, skip
      if (!pathEndElement || !pathStartElement) {
        return
      }

      const conceptStatus = pathEndElement.dataset.conceptStatus as ConceptState

      return {
        start: getPathStartFromElement(pathStartElement),
        end: getPathEndFromElement(pathEndElement),
        state: getPathState(conceptStatus),
      }
    })
    .filter(isConceptPath)
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
function getPathState(conceptStatus: ConceptState): ConceptPathState {
  switch (conceptStatus) {
    case ConceptState.Unlocked:
    case ConceptState.InProgress:
      return ConceptPathState.Available
    case ConceptState.Completed:
      return ConceptPathState.Completed
    default:
      return ConceptPathState.Unavailable
  }
}
