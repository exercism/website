// Deps
import React from 'react'

// Test deps
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'

// Component
import { SubmissionsSummaryTable } from '../../../../app/javascript/components/example/SubmissionsSummaryTable.tsx'

test('renders component', () => {
  const { container, getByText } = render(
    <SubmissionsSummaryTable
      solutionId={1}
      submissions={[{ id: 1, testsStatus: 'passed' }]}
    />
  )

  expect(getByText('1: passed')).toBeInTheDocument()
})
