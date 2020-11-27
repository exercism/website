// Deps
import React from 'react'
import '@testing-library/jest-dom'

// Test deps
import { render, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'

// Component
import { ConceptMap } from '../../../../app/javascript/components/concept-map/ConceptMap'
import { IConceptMap } from '../../../../app/javascript/components/concept-map/concept-map-types'

describe('<ConceptMap />', () => {
  test('renders empty component', async () => {
    const config: IConceptMap = {
      concepts: [],
      levels: [[]],
      connections: [],
      status: {},
      exerciseCounts: {},
    }

    const renderedConceptMap = renderConceptMap(config)
    await waitForConceptMapReady(renderedConceptMap, config)
    const map = renderedConceptMap.container.querySelector('.c-concepts-map')
    expect(map).not.toBeNull()
  })

  test('renders single incomplete concept', async () => {
    const testConcept = concept('test')
    const config: IConceptMap = {
      concepts: [testConcept],
      levels: [[testConcept.slug]],
      connections: [],
      status: { test: 'unavailable' },
      exerciseCounts: { test: { exercises: 1, exercisesCompleted: 0 } },
    }

    const renderedConceptMap = renderConceptMap(config)
    await waitForConceptMapReady(renderedConceptMap, config)

    expect(renderedConceptMap.queryByText('Test')).toBeInTheDocument()
    expect(
      renderedConceptMap.queryByTitle('You have mastered this concept')
    ).not.toBeInTheDocument()
  })

  test('renders single completed concept', async () => {
    const testConcept = concept('test')

    const config: IConceptMap = {
      concepts: [testConcept],
      levels: [[testConcept.slug]],
      connections: [],
      status: { test: 'unavailable' },
      exerciseCounts: { test: { exercises: 1, exercisesCompleted: 1 } },
    }

    const renderedConceptMap = renderConceptMap(config)
    await waitForConceptMapReady(renderedConceptMap, config)

    expect(renderedConceptMap.queryByText('Test')).toBeInTheDocument()
    expect(
      renderedConceptMap.queryByTitle('You have mastered this concept')
    ).toBeInTheDocument()
  })
})

const renderConceptMap = (config: IConceptMap) =>
  render(
    <ConceptMap
      concepts={config.concepts}
      levels={config.levels}
      connections={config.connections}
      status={config.status}
      exerciseCounts={config.exerciseCounts}
    />
  )

const waitForConceptMapReady = async (
  renderedConceptMap: ReturnType<typeof renderConceptMap>,
  config: IConceptMap
) => {
  await Promise.all(
    config.concepts
      .map((concept) => concept.name)
      .map((conceptName) =>
        waitFor(() =>
          expect(renderedConceptMap.getByText(conceptName)).toBeInTheDocument()
        )
      )
  )
}

const concept = (conceptName: string) => {
  return {
    slug: conceptName,
    name: slugToTitlecase(conceptName),
    webUrl: `link-for-${conceptName}`,
    tooltipUrl: `tooltop-link-for${conceptName}`,
  }
}

function slugToTitlecase(slug: string): string {
  return slug
    .split('-')
    .map((part) => part[0].toUpperCase() + part.substr(1))
    .join(' ')
}
