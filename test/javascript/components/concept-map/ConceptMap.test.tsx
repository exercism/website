// Deps
import React from 'react'
import '@testing-library/jest-dom'

// Test deps
import { act, render, waitFor, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'

// Component
import { default as ConceptMap } from '@/components/concept-map/ConceptMap'
import { IConceptMap } from '@/components/concept-map/concept-map-types'

describe('<ConceptMap />', () => {
  test('renders empty component', async () => {
    const config: IConceptMap = {
      concepts: [],
      levels: [[]],
      connections: [],
      status: {},
      exercisesData: [],
    }

    await renderConceptMap(config)
    const map = document.querySelector('.c-concepts-map')
    expect(map).not.toBeNull()
  })

  test('renders single incomplete concept', async () => {
    const testConcept = concept('test')
    const config: IConceptMap = {
      concepts: [testConcept],
      levels: [[testConcept.slug]],
      connections: [],
      status: { test: 'available' },
      exercisesData: {
        test: [{ status: 'available' }],
      },
    }

    await renderConceptMap(config)

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
      exercisesData: {
        test: [{ status: 'completed' }],
      },
    }

    await renderConceptMap(config)

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
      exercisesData: {
        testTest: [{ status: 'completed' }],
      },
    }

    await renderConceptMap(config)

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
      exercisesData: {
        testA: [{ status: 'completed' }],
        testB: [{ status: 'available' }],
      },
    }

    await renderConceptMap(config)

    expect(screen.queryByText('Test A')).toBeInTheDocument()
    expect(screen.queryByText('Test B')).toBeInTheDocument()
    expect(screen.queryByTestId('path-test-a-test-b')).toBeInTheDocument()
  })
})

const renderConceptMap = async (config: IConceptMap) =>
  await act(async () => {
    render(
      <ConceptMap
        concepts={config.concepts}
        levels={config.levels}
        connections={config.connections}
        status={config.status}
        exercisesData={config.exercisesData}
      />
    )
  })

const concept = (conceptSlug: string) => {
  return {
    slug: conceptSlug,
    name: slugToTitleCase(conceptSlug),
    webUrl: `link-for-${conceptSlug}`,
    tooltipUrl: `tooltip-link-for${conceptSlug}`,
  }
}

function slugToTitleCase(slug: string): string {
  return slug
    .split('-')
    .map((part) => part[0].toUpperCase() + part.substr(1))
    .join(' ')
}
