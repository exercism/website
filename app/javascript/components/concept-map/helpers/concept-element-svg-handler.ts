import { triggerVisibility } from './concept-visibility-handler'

type ElementRef = HTMLElement | null
type ElementRefPair = { startElementRef: ElementRef; endElementRef: ElementRef }
export type ElementReducer = (
  prev: ElementRefPair,
  next: ElementRefPair
) => ElementRefPair

const CONCEPTS_BY_SLUG: { [key: string]: HTMLElement } = {}

const ELEMENT_DISPATCHERS_BY_SLUG: {
  [key: string]: [React.Dispatch<ElementRefPair>, string, string][]
} = {}

// function to allow Concept to emit itself
export const emitConceptElement = (
  slug: string,
  element?: HTMLElement | null
): void => {
  if (!element) {
    delete CONCEPTS_BY_SLUG[slug]
    ELEMENT_DISPATCHERS_BY_SLUG[slug]?.forEach(([dispatcher, ,]) =>
      dispatcher({ startElementRef: null, endElementRef: null })
    )
    return
  }

  CONCEPTS_BY_SLUG[slug] = element

  ELEMENT_DISPATCHERS_BY_SLUG[slug]?.forEach(([dispatcher, start, end]) => {
    if (CONCEPTS_BY_SLUG[start] && CONCEPTS_BY_SLUG[end]) {
      dispatcher({
        startElementRef: CONCEPTS_BY_SLUG[start],
        endElementRef: CONCEPTS_BY_SLUG[end],
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
  const startElementDispatchers =
    ELEMENT_DISPATCHERS_BY_SLUG[startConceptSlug] ?? []
  startElementDispatchers.push([dispatcher, startConceptSlug, endConceptSlug])
  ELEMENT_DISPATCHERS_BY_SLUG[startConceptSlug] = startElementDispatchers

  const endElementDispatchers =
    ELEMENT_DISPATCHERS_BY_SLUG[endConceptSlug] ?? []
  endElementDispatchers.push([dispatcher, startConceptSlug, endConceptSlug])
  ELEMENT_DISPATCHERS_BY_SLUG[endConceptSlug] = endElementDispatchers

  if (CONCEPTS_BY_SLUG[startConceptSlug] && CONCEPTS_BY_SLUG[endConceptSlug]) {
    dispatcher({
      startElementRef: CONCEPTS_BY_SLUG[startConceptSlug],
      endElementRef: CONCEPTS_BY_SLUG[endConceptSlug],
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
  const startElementDispatchers =
    ELEMENT_DISPATCHERS_BY_SLUG[startConceptSlug] ?? []
  const startDispatcherIndex = startElementDispatchers.findIndex(
    ([startDispatcher, ,]) => startDispatcher === dispatcher
  )
  if (startDispatcherIndex > -1) {
    startElementDispatchers.splice(startDispatcherIndex, 1)
  }

  const endElementDispatchers =
    ELEMENT_DISPATCHERS_BY_SLUG[endConceptSlug] ?? []
  const endDispatcherIndex = endElementDispatchers.findIndex(
    ([endHandler, ,]) => endHandler === dispatcher
  )
  if (endDispatcherIndex > -1) {
    endElementDispatchers.splice(endDispatcherIndex, 1)
  }
}
