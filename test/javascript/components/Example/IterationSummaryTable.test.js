// Deps
import React from 'react'

// Test deps
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'

// Component
import { IterationsSummaryTable } from '../../../../app/javascript/components/Example/IterationsSummaryTable.jsx'

test('renders component', () => {
  const { container, getByText } = render(
    <IterationsSummaryTable
      solutionId={1}
      iterations={[{ id: 1, testsStatus: 'passed' }]}
    />
  )

  expect(getByText('1: passed')).toBeInTheDocument()
})
