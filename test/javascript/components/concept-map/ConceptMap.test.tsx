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
import { ConceptMap } from '../../../../app/javascript/components/concept-map/ConceptMap'
import {
  ConceptState,
  IConcept as Concept,
} from '../../../../app/javascript/components/concept-map/concept-types'
import { ConceptConnection } from '../../../../app/javascript/components/concept-map/concept-connection-types'
import { ConceptLayer } from '../../../../app/javascript/components/concept-map/concept-map-types'

describe('<ConceptMap />', () => {
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
    slug: conceptName,
    name: slugToTitlecase(conceptName),
    web_url: `link-for-${conceptName}`,
    status: state,
  }
}

const renderMap = (
  concepts: Concept[],
  levels: ConceptLayer[],
  connections: ConceptConnection[]
) => {
  return render(
    <ConceptMap concepts={concepts} levels={levels} connections={connections} />
  )
}

function slugToTitlecase(slug: string): string {
  return slug
    .split('-')
    .map((part) => part[0].toUpperCase() + part.substr(1))
    .join(' ')
}
