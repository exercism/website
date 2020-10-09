// Deps
import React from 'react'

// Test deps
import {
  getByTestId,
  getByText,
  getByTitle,
  queryByTitle,
  render,
} from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'

// Component
import { ConceptsMap } from '../../../../app/javascript/components/concepts-map/ConceptsMap'
import {
  ConceptState,
  IConcept as Concept,
} from '../../../../app/javascript/components/concepts-map/concept-types'
import { ConceptConnection } from '../../../../app/javascript/components/concepts-map/concept-connection-types'
import { ConceptLayer } from '../../../../app/javascript/components/concepts-map/concepts-map-types'

describe('<ConceptsMap />', () => {
  test('renders empty component', () => {
    const { container } = renderMap([], [], [])
    const map = container.querySelector('.c-concepts-map')
    expect(map).not.toBeNull()
  })

  test('renders single incomplete concept', () => {
    const testConcept = concept('test')
    const { container } = renderMap([testConcept], [[testConcept.slug]], [])
    const conceptEl = getByText(container, 'Test')
    const completeIconEl = queryByTitle(container, 'completed')
    expect(completeIconEl).toBeNull()
  })

  test('renders single completed concept', () => {
    const testConcept = concept('test', { state: ConceptState.Completed })
    const { container } = renderMap([testConcept], [[testConcept.slug]], [])
    const conceptEl = getByText(container, 'Test')
    const completeIconEl = getByTitle(container, 'completed')
  })
})

const concept = (
  conceptName: string,
  options: {
    index?: number
    state?: ConceptState
  } = {}
): Concept => {
  const index = options.index ?? 0
  const state = options.state ?? ConceptState.Locked

  return {
    index: index,
    slug: conceptName,
    web_url: `link-for-${conceptName}`,
    status: state,
  }
}

const renderMap = (
  concepts: Concept[],
  layout: ConceptLayer[],
  connections: ConceptConnection[]
) => {
  return render(
    <ConceptsMap
      concepts={concepts}
      layout={layout}
      connections={connections}
    />
  )
}
