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
  ConceptStatus,
  IConcept as Concept,
  ConceptConnection,
  ConceptLayer,
} from '../../../../app/javascript/components/concept-map/concept-map-types'

describe('<ConceptMap />', () => {
  test('renders empty component', () => {
    const { container } = renderMap([], [], [], {})
    const map = container.querySelector('.c-concepts-map')
    expect(map).not.toBeNull()
  })

  test('renders single incomplete concept', () => {
    const testConcept = concept('test')
    const { container } = renderMap([testConcept], [[testConcept.slug]], [], {
      test: 'locked',
    })
    const conceptEl = getByText(container, 'Test')
    const completeIconEl = queryByTitle(container, 'completed')
    expect(completeIconEl).toBeNull()
  })

  test('renders single completed concept', () => {
    const testConcept = concept('test', { state: 'completed' })
    const { container } = renderMap([testConcept], [[testConcept.slug]], [], {
      test: 'completed',
    })
    const conceptEl = getByText(container, 'Test')
    const completeIconEl = getByTitle(container, 'completed')
  })
})

const concept = (
  conceptName: string,
  options: {
    index?: number
    state?: ConceptStatus
  } = {}
): Concept => {
  const index = options.index ?? 0

  return {
    slug: conceptName,
    name: slugToTitlecase(conceptName),
    web_url: `link-for-${conceptName}`,
  }
}

const renderMap = (
  concepts: Concept[],
  levels: ConceptLayer[],
  connections: ConceptConnection[],
  status: { [key: string]: ConceptStatus }
) => {
  return render(
    <ConceptMap
      concepts={concepts}
      levels={levels}
      connections={connections}
      status={status}
    />
  )
}

function slugToTitlecase(slug: string): string {
  return slug
    .split('-')
    .map((part) => part[0].toUpperCase() + part.substr(1))
    .join(' ')
}
