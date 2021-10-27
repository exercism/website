// Deps
import React from 'react'

// Test deps
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'

// Component
import { SubmissionsSummaryTable } from '../../../../app/javascript/components/maintaining/SubmissionsSummaryTable'

test('renders component', () => {
  const { container, getByText } = render(
    <SubmissionsSummaryTable
      submissions={[
        {
          uuid: 1,
          testsStatus: 'passed',
          representationStatus: 'queued',
          analysisStatus: 'approved',
        },
      ]}
    />
  )

  expect(getByText('passed')).toBeInTheDocument()
  expect(getByText('queued')).toBeInTheDocument()
  expect(getByText('approved')).toBeInTheDocument()
})
