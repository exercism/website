// Deps
import React from 'react'

// Test deps
import { getByTestId, render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'

// Component
import { ConceptGraph } from '../../../../app/javascript/components/concept-graph/ConceptGraph'
import {
  ConceptState,
  IConcept as Concept,
} from '../../../../app/javascript/components/concept-graph/concept-types'
import { ConceptConnection } from '../../../../app/javascript/components/concept-graph/concept-connection-types'
import { ConceptLayer } from '../../../../app/javascript/components/concept-graph/concept-graph-types'

describe('<ConceptGraph />', () => {
  test('renders empty component', () => {
    const { container } = renderGraph([], [], [])
    const graph = container.querySelector('.c-concept-graph')
    expect(graph).not.toBeNull()
  })

  // TODO: Fix once webpacker 5 fix merged, fails on type error
  test('renders single concept', () => {
    const { container } = renderGraph([concept('test')], [['test']], [])
    const conceptEl = getByTestId(container, 'concept-test')
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

const renderGraph = (
  concepts: Concept[],
  layout: ConceptLayer[],
  connections: ConceptConnection[]
) => {
  return render(
    <ConceptGraph
      concepts={concepts}
      layout={layout}
      connections={connections}
    />
  )
}
