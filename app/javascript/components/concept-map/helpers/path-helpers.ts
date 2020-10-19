import {
  ConceptPath,
  ConceptConnection,
  ConceptPathCoordinate,
  ConceptPathState,
} from '../concept-connection-types'

import { ConceptState } from '../concept-types'

import { conceptSlugToId } from '../Concept'

type CategorizedConceptPaths = {
  unavailable: ConceptPath[]
  available: ConceptPath[]
  completed: ConceptPath[]
}

export function determinePathTypes(
  connections: ConceptConnection[],
  activeConcept: string | null = null,
  matchActive: boolean | null = null
): CategorizedConceptPaths {
  const paths: CategorizedConceptPaths = {
    unavailable: [],
    available: [],
    completed: [],
  }

  connections.forEach(({ from, to }) => {
    // If looking to match only active paths, and if both ends of the path
    // don't connect to the active Concept, then skip
    if (
      matchActive === true &&
      to !== activeConcept &&
      from !== activeConcept
    ) {
      return
    }

    // If looking to match only inactive edges, and if either end of the path
    // connect to the active Concept, then skip
    if (
      matchActive === false &&
      (to === activeConcept || from === activeConcept)
    ) {
      return
    }

    // If the start or end concept doesn't exist for some reason, skip
    const pathEndElement = document.getElementById(conceptSlugToId(to))
    if (!pathEndElement) {
      return
    }
    const pathStartElement = document.getElementById(conceptSlugToId(from))
    if (!pathStartElement) {
      return
    }

    const conceptStatus = pathEndElement.dataset.conceptStatus as ConceptState
    const conceptPath = {
      start: getPathStartFromElement(pathStartElement),
      end: getPathEndFromElement(pathEndElement),
      state: getPathState(conceptStatus),
    }

    switch (conceptPath.state) {
      case ConceptPathState.Available:
        paths.available.push(conceptPath)
        break
      case ConceptPathState.Completed:
        paths.completed.push(conceptPath)
        break
      default:
        paths.unavailable.push(conceptPath)
        break
    }
  })

  return paths
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
