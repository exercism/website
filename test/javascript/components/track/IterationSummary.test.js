import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { IterationSummary } from '../../../../app/javascript/components/track/IterationSummary'

test('shows details', async () => {
  render(
    <IterationSummary
      iteration={{
        idx: 2,
        submissionMethod: 'cli',
        createdAt: Date.now() - 1,
        testsStatus: 'queued',
        numEssentialAutomatedComments: 2,
      }}
    />
  )

  expect(screen.getByText('Iteration 2')).toBeInTheDocument()
  expect(screen.getByTitle('Submitted via CLI')).toBeInTheDocument()
  expect(screen.getByTestId('details')).toHaveTextContent(
    'Submitted via CLI, a few seconds ago'
  )
  expect(
    screen.getByRole('status', { name: 'Processing status' })
  ).toHaveTextContent('Passed')
  expect(
    screen.getByRole('status', { name: 'Analysis status' })
  ).toHaveTextContent('2')
})
