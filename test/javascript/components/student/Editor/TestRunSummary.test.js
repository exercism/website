import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TestRunSummary } from '../../../../../app/javascript/components/student/editor/TestRunSummary'

test('hides cancel button if test run has resolved', async () => {
  const { queryByText } = render(
    <TestRunSummary submission={{ testsStatus: 'passed' }} />
  )

  expect(queryByText('Cancel')).not.toBeInTheDocument()
})
