// Deps
import React from 'react'
import '@testing-library/jest-dom'

// Test deps
import { screen, render, waitFor } from '@testing-library/react'
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

    const { container } = await waitForConceptMapReady(config)
    const map = container.querySelector('.c-concepts-map')
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

    await waitForConceptMapReady(config)

    expect(
      screen.queryByTitle('You have mastered this concept')
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

    await waitForConceptMapReady(config)

    expect(
      screen.queryByTitle('You have mastered this concept')
    ).toBeInTheDocument()
  })
})

const waitForConceptMapReady = async (config: IConceptMap) => {
  const renderResult = render(
    <ConceptMap
      concepts={config.concepts}
      levels={config.levels}
      connections={config.connections}
      status={config.status}
      exerciseCounts={config.exerciseCounts}
    />
  )

  await Promise.all(
    config.concepts
      .map((concept) => concept.name)
      .map((conceptName) =>
        waitFor(() => expect(screen.getByText(conceptName)).toBeInTheDocument())
      )
  )

  return renderResult
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
