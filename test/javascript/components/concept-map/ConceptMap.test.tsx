// Deps
import React from 'react'
import '@testing-library/jest-dom'

// Test deps
import { screen, render, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'

// Component
import { ConceptMap } from '../../../../app/javascript/components/concept-map/ConceptMap'

describe('<ConceptMap />', () => {
  test('renders empty component', () => {
    const { container } = render(
      <ConceptMap
        concepts={[]}
        levels={[[]]}
        connections={[]}
        status={{}}
        exercise_counts={{}}
      />
    )
    const map = container.querySelector('.c-concepts-map')
    expect(map).not.toBeNull()
  })

  test('renders single incomplete concept', async () => {
    const testConcept = concept('test')

    render(
      <ConceptMap
        concepts={[testConcept]}
        levels={[[testConcept.slug]]}
        connections={[]}
        status={{
          test: 'unavailable',
        }}
        exercise_counts={{
          test: {
            exercises: 1,
            exercises_completed: 0,
          },
        }}
      />
    )

    await waitFor(() => {
      expect(screen.getByText('Test')).toBeInTheDocument()
      expect(
        screen.queryByTitle('You have mastered this concept')
      ).not.toBeInTheDocument()
    })
  })

  test('renders single completed concept', async () => {
    const testConcept = concept('test')
    render(
      <ConceptMap
        concepts={[testConcept]}
        levels={[[testConcept.slug]]}
        connections={[]}
        status={{
          test: 'completed',
        }}
        exercise_counts={{
          test: {
            exercises: 1,
            exercises_completed: 1,
          },
        }}
      />
    )

    await waitFor(() => {
      expect(screen.getByText('Test')).toBeInTheDocument()
      expect(
        screen.getByTitle('You have mastered this concept')
      ).toBeInTheDocument()
    })
  })
})

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
