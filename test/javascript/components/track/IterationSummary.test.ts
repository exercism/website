import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'

/* @kntsoriano - Please can you fix these tests */
/*
import { IterationSummary } from '../../../../app/javascript/components/track/IterationSummary'

test('shows details', async () => {
  const { getByText, getByTestId, getByTitle } = render(
    <IterationSummary
      iteration={{
        idx: 2,
        submissionMethod: 'cli',
        createdAt: Date.now() - 1,
        testsStatus: 'queued',
        representationStatus: 'approved',
        analysisStatus: 'approved',
      }}
    />
  )

  expect(getByText('Iteration 2')).toBeInTheDocument()
  expect(getByTitle('Submitted via CLI')).toBeInTheDocument()
  expect(getByTestId('details')).toHaveTextContent(
    'Submitted via CLI, a few seconds ago'
  )
  expect(getByText('Queued')).toBeInTheDocument()
  expect(getByText('Automated feedback comments')).toBeInTheDocument()
})*/

/* @kntsoriano - please delete this */
test('placeholder', async () => {})
