import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TestSummary } from '../../../../../app/javascript/components/student/Editor/TestSummary'
import { TestStatus } from '../../../../../app/javascript/components/student/Editor/TestRunSummary'

test('shows test details', async () => {
  const test = {
    name: 'first test',
    status: TestStatus.PASS,
    output: 'debug',
  }

  const { queryByText } = render(<TestSummary test={test} />)

  expect(queryByText('Passed: first test')).toBeInTheDocument()
  expect(queryByText('Output: debug')).toBeInTheDocument()
})

test('hides output', async () => {
  const test = {
    name: 'first test',
    status: TestStatus.PASS,
    output: '',
  }

  const { queryByText } = render(<TestSummary test={test} />)

  expect(queryByText('Output:')).not.toBeInTheDocument()
})
