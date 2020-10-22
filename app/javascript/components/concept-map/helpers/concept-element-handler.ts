export interface IDrawHandler {
  (
    pathStartElement: HTMLElement | null,
    pathEndElement: HTMLElement | null
  ): void
}

const CONCEPT_BOX: { [key: string]: HTMLElement } = {}

const DRAW_HANDLER_BOX: {
  [key: string]: [IDrawHandler, string, string][]
} = {}

// function to allow Concept to emit itself
export const emitConceptElement = (
  slug: string,
  element?: HTMLElement | null
): void => {
  if (!element) {
    delete CONCEPT_BOX[slug]
    DRAW_HANDLER_BOX[slug].forEach(([handler, ,]) => handler(null, null))
    return
  }

  CONCEPT_BOX[slug] = element

  DRAW_HANDLER_BOX[slug]?.forEach(([handler, from, to]) => {
    if (CONCEPT_BOX[from] && CONCEPT_BOX[to]) {
      handler(CONCEPT_BOX[from], CONCEPT_BOX[to])
    }
  })
}

export const addDrawHandler = (
  handler: IDrawHandler,
  fromConceptSlug: string,
  toConceptSlug: string
) => {
  const fromDrawHandlers = DRAW_HANDLER_BOX[fromConceptSlug] ?? []
  fromDrawHandlers.push([handler, fromConceptSlug, toConceptSlug])
  DRAW_HANDLER_BOX[fromConceptSlug] = fromDrawHandlers

  const toDrawHandlers = DRAW_HANDLER_BOX[toConceptSlug] ?? []
  toDrawHandlers.push([handler, fromConceptSlug, toConceptSlug])
  DRAW_HANDLER_BOX[toConceptSlug] = toDrawHandlers

  if (CONCEPT_BOX[fromConceptSlug] && CONCEPT_BOX[toConceptSlug]) {
    handler(CONCEPT_BOX[fromConceptSlug], CONCEPT_BOX[toConceptSlug])
  }
}

export const removeDrawHandler = (
  handler: IDrawHandler,
  fromConceptSlug: string,
  toConceptSlug: string
) => {
  const fromDrawHandlers = DRAW_HANDLER_BOX[fromConceptSlug] ?? []
  const fromHandlerIndex = fromDrawHandlers.findIndex(
    ([fromHandler, ,]) => fromHandler === handler
  )
  if (fromHandlerIndex > -1) {
    DRAW_HANDLER_BOX[fromConceptSlug] = fromDrawHandlers.splice(
      fromHandlerIndex,
      1
    )
  }

  const toDrawHandlers = DRAW_HANDLER_BOX[toConceptSlug] ?? []
  const toHandlerIndex = toDrawHandlers.findIndex(
    ([toHandler, ,]) => toHandler === handler
  )
  if (toHandlerIndex > -1) {
    DRAW_HANDLER_BOX[toConceptSlug] = toDrawHandlers.splice(toHandlerIndex, 1)
  }
}
