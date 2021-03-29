import React from 'react'
import { screen, render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TestRunSummaryHeaderMessage } from '../../../../app/javascript/components/editor/TestRunSummaryHeaderMessage'

test('returns message for version 1 test runner', async () => {
  render(<TestRunSummaryHeaderMessage version={1} numFailedTests={2} />)

  expect(screen.getByText('Tests failed')).toBeInTheDocument()
})

test('returns message for version 2 test runner', async () => {
  render(<TestRunSummaryHeaderMessage version={2} numFailedTests={2} />)

  expect(screen.getByText('2 test failures')).toBeInTheDocument()
})
