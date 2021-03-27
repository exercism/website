// Deps
import React from 'react'
import '@testing-library/jest-dom'

// Test deps
import { render, waitFor, screen } from '@testing-library/react'
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
      exerciseStatuses: {},
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
      status: { test: 'available' },
      exerciseStatuses: {
        test: ['available'],
      },
    }

    const renderedConceptMap = renderConceptMap(config)
    await waitForConceptMapReady(renderedConceptMap, config)

    expect(screen.queryByText('Test')).toBeInTheDocument()
    expect(
      screen.queryByAltText('You have mastered this concept')
    ).not.toBeInTheDocument()
  })

  test('renders single completed concept', async () => {
    const testConcept = concept('test')

    const config: IConceptMap = {
      concepts: [testConcept],
      levels: [[testConcept.slug]],
      connections: [],
      status: { test: 'mastered' },
      exerciseStatuses: {
        test: ['complete'],
      },
    }

    const renderedConceptMap = renderConceptMap(config)
    await waitForConceptMapReady(renderedConceptMap, config)

    expect(screen.queryByText('Test')).toBeInTheDocument()
    expect(screen.queryByLabelText('Mastered Concept:')).toBeInTheDocument()
  })

  test('renders single multi-word concept', async () => {
    const testConcept = concept('test-test')

    const config: IConceptMap = {
      concepts: [testConcept],
      levels: [[testConcept.slug]],
      connections: [],
      status: { testTest: 'mastered' },
      exerciseStatuses: {
        testTest: ['complete'],
      },
    }

    const renderedConceptMap = renderConceptMap(config)
    await waitForConceptMapReady(renderedConceptMap, config)

    expect(screen.queryByText('Test Test')).toBeInTheDocument()
  })

  test('renders a path between concepts', async () => {
    const testConceptA = concept('test-a')
    const testConceptB = concept('test-b')

    const config: IConceptMap = {
      concepts: [testConceptA, testConceptB],
      levels: [[testConceptA.slug], [testConceptB.slug]],
      connections: [
        {
          from: testConceptA.slug,
          to: testConceptB.slug,
        },
      ],
      status: { test1: 'mastered', test2: 'available' },
      exerciseStatuses: {
        testA: ['complete'],
        testB: ['available'],
      },
    }

    const renderedConceptMap = renderConceptMap(config)
    await waitForConceptMapReady(renderedConceptMap, config)

    expect(screen.queryByText('Test A')).toBeInTheDocument()
    expect(screen.queryByText('Test B')).toBeInTheDocument()
    expect(screen.queryByTestId('path-test-a-test-b')).toBeInTheDocument()
  })
})

const renderConceptMap = (config: IConceptMap) =>
  render(
    <ConceptMap
      concepts={config.concepts}
      levels={config.levels}
      connections={config.connections}
      status={config.status}
      exerciseStatuses={config.exerciseStatuses}
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
    name: slugToTitleCase(conceptName),
    webUrl: `link-for-${conceptName}`,
    tooltipUrl: `tooltip-link-for${conceptName}`,
  }
}

function slugToTitleCase(slug: string): string {
  return slug
    .split('-')
    .map((part) => part[0].toUpperCase() + part.substr(1))
    .join(' ')
}
