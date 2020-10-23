import { triggerVisibility } from './concept-visibility-handler'

type ElementRef = HTMLElement | null
type ElementRefPair = { startElementRef: ElementRef; endElementRef: ElementRef }
export type ElementReducer = (
  prev: ElementRefPair,
  next: ElementRefPair
) => ElementRefPair

const CONCEPT_BOX: { [key: string]: HTMLElement } = {}

const ELEMENT_DISPATCHER_BOX: {
  [key: string]: [React.Dispatch<ElementRefPair>, string, string][]
} = {}

// function to allow Concept to emit itself
export const emitConceptElement = (
  slug: string,
  element?: HTMLElement | null
): void => {
  if (!element) {
    delete CONCEPT_BOX[slug]
    ELEMENT_DISPATCHER_BOX[slug]?.forEach(([dispatcher, ,]) =>
      dispatcher({ startElementRef: null, endElementRef: null })
    )
    return
  }

  CONCEPT_BOX[slug] = element

  ELEMENT_DISPATCHER_BOX[slug]?.forEach(([dispatcher, start, end]) => {
    if (CONCEPT_BOX[start] && CONCEPT_BOX[end]) {
      dispatcher({
        startElementRef: CONCEPT_BOX[start],
        endElementRef: CONCEPT_BOX[end],
      })
      triggerVisibility()
    }
  })
}

// function to allow Paths to register their dispatcher
export const addElementDispatcher = (
  dispatcher: React.Dispatch<ElementRefPair>,
  startConceptSlug: string,
  endConceptSlug: string
) => {
  const startElementDispatchers = ELEMENT_DISPATCHER_BOX[startConceptSlug] ?? []
  startElementDispatchers.push([dispatcher, startConceptSlug, endConceptSlug])
  ELEMENT_DISPATCHER_BOX[startConceptSlug] = startElementDispatchers

  const endElementDispatchers = ELEMENT_DISPATCHER_BOX[endConceptSlug] ?? []
  endElementDispatchers.push([dispatcher, startConceptSlug, endConceptSlug])
  ELEMENT_DISPATCHER_BOX[endConceptSlug] = endElementDispatchers

  if (CONCEPT_BOX[startConceptSlug] && CONCEPT_BOX[endConceptSlug]) {
    dispatcher({
      startElementRef: CONCEPT_BOX[startConceptSlug],
      endElementRef: CONCEPT_BOX[endConceptSlug],
    })
    triggerVisibility()
  }
}

// function to allow Path to unregister their dispatcher
export const removeElementDispatcher = (
  dispatcher: React.Dispatch<ElementRefPair>,
  startConceptSlug: string,
  endConceptSlug: string
) => {
  const startElementDispatchers = ELEMENT_DISPATCHER_BOX[startConceptSlug] ?? []
  const startDispatcherIndex = startElementDispatchers.findIndex(
    ([startDispatcher, ,]) => startDispatcher === dispatcher
  )
  if (startDispatcherIndex > -1) {
    startElementDispatchers.splice(startDispatcherIndex, 1)
  }

  const endElementDispatchers = ELEMENT_DISPATCHER_BOX[endConceptSlug] ?? []
  const endDispatcherIndex = endElementDispatchers.findIndex(
    ([endHandler, ,]) => endHandler === dispatcher
  )
  if (endDispatcherIndex > -1) {
    endElementDispatchers.splice(endDispatcherIndex, 1)
  }
}
