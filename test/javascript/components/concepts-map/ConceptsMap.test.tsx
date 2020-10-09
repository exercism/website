// Deps
import React from 'react'

// Test deps
import {
  getByTestId,
  getByText,
  getByTitle,
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

  test('renders single concept', () => {
    const { container } = renderMap([concept('test')], [['test']], [])
    const conceptEl = getByText(container, 'Test')
    expect(conceptEl).not.toBeNull()
  })
})

const concept = (
  conceptName: string,
  index: number = 0,
  state: ConceptState = ConceptState.Locked
): Concept => {
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
