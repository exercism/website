// Deps
import React from 'react'

// Test deps
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'

// Component
import { IterationsSummaryTable } from '../../../../app/javascript/components/Maintaining/IterationsSummaryTable.jsx'

test('renders component', () => {
  const { container, getByText } = render(
    <IterationsSummaryTable
      iterations={[
        {
          id: 1,
          testsStatus: 'passed',
          representationStatus: 'pending',
          analysisStatus: 'approved',
        },
      ]}
    />
  )

  expect(getByText('passed')).toBeInTheDocument()
  expect(getByText('pending')).toBeInTheDocument()
  expect(getByText('approved')).toBeInTheDocument()
})
