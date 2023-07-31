import React from 'react'
import { screen, render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TestRunSummaryByStatusHeaderMessage } from '../../../../app/javascript/components/editor/TestRunSummaryByStatusHeaderMessage'

test('returns message for version 1 test runner', async () => {
  render(<TestRunSummaryByStatusHeaderMessage version={1} numFailedTests={2} />)

  expect(screen.getByText('Tests failed')).toBeInTheDocument()
})

test('returns message for version 2 test runner', async () => {
  render(<TestRunSummaryByStatusHeaderMessage version={2} numFailedTests={2} />)

  expect(screen.getByText('2 test failures')).toBeInTheDocument()
})
