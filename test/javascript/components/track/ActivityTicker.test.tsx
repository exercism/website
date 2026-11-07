import '@/i18n/i18n'
import React from 'react'
import { render, screen } from '@testing-library/react'
import ActivityTicker from '@/components/track/ActivityTicker'
import { ExerciseWidget } from '@/components/track/activity-ticker'
import type { Metric } from '@/components/types'

jest.mock('@/channels/metricsChannel', () => ({
  MetricsChannel: jest.fn().mockImplementation(() => ({
    disconnect: jest.fn(),
  })),
}))

const exercise = {
  title: 'Lasagna',
  exerciseUrl: '/tracks/ruby/exercises/lasagna',
  iconUrl: 'https://example.com/lasagna.svg',
}

function metric(overrides: Partial<Metric>): Metric {
  return {
    type: 'start_solution_metric',
    coordinates: [0, 0],
    user: { handle: 'iHiD', avatarUrl: '', links: { self: null } },
    countryCode: 'GB',
    countryName: 'United Kingdom',
    exercise,
    occurredAt: new Date().toISOString(),
    ...overrides,
  }
}

describe('ActivityTicker', () => {
  test('ExerciseWidget renders only the exercise link, with no full stop', () => {
    const { container } = render(<ExerciseWidget exercise={exercise} />)

    expect(container.textContent).toBe('Lasagna')
  })

  test.each([
    ['start_solution_metric', 'iHiD started Lasagna.'],
    ['complete_solution_metric', 'iHiD completed Lasagna.'],
    ['submit_submission_metric', 'iHiD attempted Lasagna.'],
  ])('the English %s sentence ends with a full stop', (type, sentence) => {
    render(<ActivityTicker trackTitle="Ruby" initialData={metric({ type })} />)

    expect(screen.getByText('Lasagna').closest('div')!.textContent).toBe(
      sentence
    )
  })

  test('the English publish sentence ends with a full stop', () => {
    render(
      <ActivityTicker
        trackTitle="Ruby"
        initialData={metric({
          type: 'publish_solution_metric',
          publishedSolutionUrl: '/solutions/1',
        })}
      />
    )

    expect(screen.getByText('Lasagna').closest('div')!.textContent).toBe(
      'iHiD published a new solution for Lasagna.'
    )
  })
})
